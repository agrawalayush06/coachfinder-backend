package com.coachfinder.coachfinder_backend.provider;

import com.coachfinder.coachfinder_backend.BaseIT;
import com.coachfinder.coachfinder_backend.provider.dto.CreateProviderRequest;
import com.coachfinder.coachfinder_backend.provider.dto.UpdateProviderRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ProviderApiIT extends BaseIT {

    @Autowired
    private MockMvc mockMvc;

    private final ObjectMapper objectMapper = new ObjectMapper().findAndRegisterModules();

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Long userId1;
    private Long userId2;

    @BeforeEach
    void setUp() {
        jdbcTemplate.execute("DELETE FROM provider_activities");
        jdbcTemplate.execute("DELETE FROM providers");
        jdbcTemplate.execute("DELETE FROM users");

        userId1 = jdbcTemplate.queryForObject(
                "INSERT INTO users (email, name, role) VALUES ('coach1@example.com', 'Coach One', 'COACH') RETURNING id",
                Long.class
        );
        userId2 = jdbcTemplate.queryForObject(
                "INSERT INTO users (email, name, role) VALUES ('coach2@example.com', 'Coach Two', 'COACH') RETURNING id",
                Long.class
        );
    }

    @Test
    void createProvider_Returns201() throws Exception {
        CreateProviderRequest request = new CreateProviderRequest(userId1, "INDIVIDUAL", "John Coaching", "Delhi", 28.61, 77.20);

        mockMvc.perform(post("/v1/providers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.userId").value(userId1))
                .andExpect(jsonPath("$.name").value("John Coaching"));
    }

    @Test
    void getProviderById_UnknownId_Returns404WithErrorJsonShape() throws Exception {
        mockMvc.perform(get("/v1/providers/99999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.timestamp").exists())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.message").value("Provider not found with id: 99999"))
                .andExpect(jsonPath("$.fieldErrors").isArray());
    }

    @Test
    void createProvider_InvalidBody_Returns400WithFieldErrors() throws Exception {
        CreateProviderRequest request = new CreateProviderRequest(userId1, "", "", "", null, null);

        mockMvc.perform(post("/v1/providers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("Validation failed for request parameters"))
                .andExpect(jsonPath("$.fieldErrors", hasSize(greaterThanOrEqualTo(3))));
    }

    @Test
    void createProvider_DuplicateProviderForSameUser_Returns409() throws Exception {
        CreateProviderRequest request1 = new CreateProviderRequest(userId1, "INDIVIDUAL", "John Coaching 1", "Delhi", null, null);
        mockMvc.perform(post("/v1/providers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request1)))
                .andExpect(status().isCreated());

        CreateProviderRequest request2 = new CreateProviderRequest(userId1, "INDIVIDUAL", "John Coaching 2", "Delhi", null, null);
        mockMvc.perform(post("/v1/providers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request2)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.message").value("Provider already exists for user id: " + userId1));
    }

    @Test
    void searchProviders_ByCityIgnoresCase() throws Exception {
        CreateProviderRequest req = new CreateProviderRequest(userId1, "INDIVIDUAL", "Capital Academy", "New Delhi", null, null);
        mockMvc.perform(post("/v1/providers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated());

        mockMvc.perform(get("/v1/providers").param("city", "new delhi"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", hasSize(1)))
                .andExpect(jsonPath("$.content[0].name").value("Capital Academy"));
    }

    @Test
    void searchProviders_ByActivityId_ReturnsRightProviders() throws Exception {
        CreateProviderRequest req1 = new CreateProviderRequest(userId1, "INDIVIDUAL", "Cricket Coach", "Delhi", null, null);
        String res1 = mockMvc.perform(post("/v1/providers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req1)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        Long providerId1 = objectMapper.readTree(res1).get("id").asLong();

        CreateProviderRequest req2 = new CreateProviderRequest(userId2, "INDIVIDUAL", "Music Teacher", "Delhi", null, null);
        mockMvc.perform(post("/v1/providers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req2)))
                .andExpect(status().isCreated());

        Long cricketId = jdbcTemplate.queryForObject("SELECT id FROM activities WHERE name = 'Cricket'", Long.class);

        jdbcTemplate.update(
                "INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session) VALUES (?, ?, 'INTERMEDIATE', 500.00)",
                providerId1, cricketId
        );

        mockMvc.perform(get("/v1/providers").param("activityId", String.valueOf(cricketId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", hasSize(1)))
                .andExpect(jsonPath("$.content[0].name").value("Cricket Coach"));
    }

    @Test
    void updateProvider_Returns200() throws Exception {
        CreateProviderRequest req = new CreateProviderRequest(userId1, "INDIVIDUAL", "Old Name", "Delhi", null, null);
        String res = mockMvc.perform(post("/v1/providers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        Long providerId = objectMapper.readTree(res).get("id").asLong();

        UpdateProviderRequest updateReq = new UpdateProviderRequest("ACADEMY", "Updated Name Academy", "Delhi", 28.5, 77.1);

        mockMvc.perform(put("/v1/providers/" + providerId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.type").value("ACADEMY"))
                .andExpect(jsonPath("$.name").value("Updated Name Academy"));
    }

    @Test
    void deleteProvider_Returns204AndLaterGetReturns404() throws Exception {
        CreateProviderRequest req = new CreateProviderRequest(userId1, "INDIVIDUAL", "Temp Provider", "Delhi", null, null);
        String res = mockMvc.perform(post("/v1/providers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        Long providerId = objectMapper.readTree(res).get("id").asLong();

        mockMvc.perform(delete("/v1/providers/" + providerId))
                .andExpect(status().isNoContent());

        mockMvc.perform(get("/v1/providers/" + providerId))
                .andExpect(status().isNotFound());
    }
}
