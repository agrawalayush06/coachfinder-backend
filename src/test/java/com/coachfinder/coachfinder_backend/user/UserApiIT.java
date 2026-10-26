package com.coachfinder.coachfinder_backend.user;

import com.coachfinder.coachfinder_backend.BaseIT;
import com.coachfinder.coachfinder_backend.user.dto.CreateUserRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class UserApiIT extends BaseIT {

    @Autowired
    private MockMvc mockMvc;

    private final ObjectMapper objectMapper = new ObjectMapper().findAndRegisterModules();

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void setUp() {
        jdbcTemplate.execute("DELETE FROM provider_activities");
        jdbcTemplate.execute("DELETE FROM providers");
        jdbcTemplate.execute("DELETE FROM users");
    }

    @Test
    void createUser_Returns201() throws Exception {
        CreateUserRequest request = new CreateUserRequest("testuser@example.com", "Test User", "COACH");

        mockMvc.perform(post("/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.email").value("testuser@example.com"))
                .andExpect(jsonPath("$.name").value("Test User"))
                .andExpect(jsonPath("$.role").value("COACH"))
                .andExpect(jsonPath("$.createdAt").exists());
    }

    @Test
    void createUser_DuplicateEmail_Returns409() throws Exception {
        CreateUserRequest request1 = new CreateUserRequest("duplicate@example.com", "User One", "USER");
        mockMvc.perform(post("/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request1)))
                .andExpect(status().isCreated());

        CreateUserRequest request2 = new CreateUserRequest("duplicate@example.com", "User Two", "USER");
        mockMvc.perform(post("/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request2)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.message").value("User with email 'duplicate@example.com' already exists"));
    }

    @Test
    void createUser_RoleAdmin_RejectedWith400() throws Exception {
        CreateUserRequest request = new CreateUserRequest("admin@example.com", "Admin User", "ADMIN");

        mockMvc.perform(post("/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("Role 'ADMIN' is not allowed"));
    }
}
