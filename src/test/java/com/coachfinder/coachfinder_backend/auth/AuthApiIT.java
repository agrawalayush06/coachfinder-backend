package com.coachfinder.coachfinder_backend.auth;

import com.coachfinder.coachfinder_backend.BaseIT;
import com.coachfinder.coachfinder_backend.auth.dto.AuthResponse;
import com.coachfinder.coachfinder_backend.auth.dto.LoginRequest;
import com.coachfinder.coachfinder_backend.auth.dto.RegisterRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class AuthApiIT extends BaseIT {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final ObjectMapper objectMapper = new ObjectMapper().findAndRegisterModules();

    @BeforeEach
    void setUp() {
        jdbcTemplate.execute("DELETE FROM provider_activities");
        jdbcTemplate.execute("DELETE FROM providers");
        jdbcTemplate.execute("DELETE FROM users");
    }

    @Test
    void register_Returns201AndJwtToken() throws Exception {
        RegisterRequest request = new RegisterRequest("coach.test@example.com", "password123", "Coach Test", "COACH");

        mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token").isString())
                .andExpect(jsonPath("$.token", not(emptyOrNullString())))
                .andExpect(jsonPath("$.user.id").exists())
                .andExpect(jsonPath("$.user.email").value("coach.test@example.com"))
                .andExpect(jsonPath("$.user.name").value("Coach Test"))
                .andExpect(jsonPath("$.user.role").value("COACH"));
    }

    @Test
    void register_DuplicateEmail_Returns409() throws Exception {
        RegisterRequest request1 = new RegisterRequest("dup@example.com", "password123", "User One", "STUDENT");
        mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request1)))
                .andExpect(status().isCreated());

        RegisterRequest request2 = new RegisterRequest("dup@example.com", "differentPassword", "User Two", "STUDENT");
        mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request2)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.message").value("User with email 'dup@example.com' already exists"));
    }

    @Test
    void register_AdminRole_Returns400() throws Exception {
        RegisterRequest request = new RegisterRequest("admin@example.com", "password123", "Admin User", "ADMIN");

        mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("Role 'ADMIN' is not allowed"));
    }

    @Test
    void login_Success_Returns200AndValidToken() throws Exception {
        RegisterRequest regRequest = new RegisterRequest("login.user@example.com", "secret456", "Login User", "STUDENT");
        mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(regRequest)))
                .andExpect(status().isCreated());

        LoginRequest loginRequest = new LoginRequest("login.user@example.com", "secret456");
        mockMvc.perform(post("/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isString())
                .andExpect(jsonPath("$.token", not(emptyOrNullString())))
                .andExpect(jsonPath("$.user.email").value("login.user@example.com"));
    }

    @Test
    void login_WrongPassword_Returns401() throws Exception {
        RegisterRequest regRequest = new RegisterRequest("user.wrong@example.com", "correctPassword", "Wrong Pwd User", "STUDENT");
        mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(regRequest)))
                .andExpect(status().isCreated());

        LoginRequest loginRequest = new LoginRequest("user.wrong@example.com", "badPassword");
        mockMvc.perform(post("/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401));
    }

    @Test
    void login_UnknownEmail_Returns401() throws Exception {
        LoginRequest loginRequest = new LoginRequest("unknown@example.com", "anyPassword");
        mockMvc.perform(post("/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401));
    }

    @Test
    void getMe_WithoutToken_Returns401() throws Exception {
        mockMvc.perform(get("/v1/auth/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401));
    }

    @Test
    void getMe_WithValidToken_Returns200() throws Exception {
        RegisterRequest regRequest = new RegisterRequest("me.user@example.com", "password123", "Me User", "COACH");
        MvcResult result = mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(regRequest)))
                .andExpect(status().isCreated())
                .andReturn();

        AuthResponse authResponse = objectMapper.readValue(result.getResponse().getContentAsString(), AuthResponse.class);
        String token = authResponse.getToken();

        mockMvc.perform(get("/v1/auth/me")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("me.user@example.com"))
                .andExpect(jsonPath("$.name").value("Me User"))
                .andExpect(jsonPath("$.role").value("COACH"));
    }
}
