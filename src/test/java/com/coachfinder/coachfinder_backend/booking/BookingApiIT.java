package com.coachfinder.coachfinder_backend.booking;

import com.coachfinder.coachfinder_backend.BaseIT;
import com.coachfinder.coachfinder_backend.auth.dto.AuthResponse;
import com.coachfinder.coachfinder_backend.auth.dto.RegisterRequest;
import com.coachfinder.coachfinder_backend.booking.dto.CreateBookingRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class BookingApiIT extends BaseIT {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final ObjectMapper objectMapper = new ObjectMapper().findAndRegisterModules();

    private Long providerId;
    private String studentToken;
    private Long studentUserId;
    private String otherStudentToken;

    @BeforeEach
    void setUp() throws Exception {
        jdbcTemplate.execute("DELETE FROM bookings");
        jdbcTemplate.execute("DELETE FROM provider_activities");
        jdbcTemplate.execute("DELETE FROM providers");
        jdbcTemplate.execute("DELETE FROM users");

        // 1. Register Coach and insert provider
        AuthResponse coachAuth = registerUser("coach@example.com", "password123", "Head Coach", "COACH");
        Long coachUserId = coachAuth.getUser().getId();

        jdbcTemplate.update(
                "INSERT INTO providers (user_id, type, name, city, lat, lng) VALUES (?, ?, ?, ?, ?, ?)",
                coachUserId, "COACH", "Elite Coach Academy", "San Francisco", 37.7749, -122.4194
        );
        providerId = jdbcTemplate.queryForObject("SELECT id FROM providers WHERE user_id = ?", Long.class, coachUserId);

        // 2. Register Student 1
        AuthResponse studentAuth = registerUser("student1@example.com", "password123", "Alice Student", "STUDENT");
        studentToken = studentAuth.getToken();
        studentUserId = studentAuth.getUser().getId();

        // 3. Register Student 2
        AuthResponse otherStudentAuth = registerUser("student2@example.com", "password123", "Bob Student", "STUDENT");
        otherStudentToken = otherStudentAuth.getToken();
    }

    private AuthResponse registerUser(String email, String password, String name, String role) throws Exception {
        RegisterRequest req = new RegisterRequest(email, password, name, role);
        MvcResult result = mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andReturn();
        return objectMapper.readValue(result.getResponse().getContentAsString(), AuthResponse.class);
    }

    @Test
    void createBooking_Success() throws Exception {
        Instant sessionTime = Instant.now().plus(2, ChronoUnit.DAYS).truncatedTo(ChronoUnit.SECONDS);
        CreateBookingRequest request = new CreateBookingRequest(
                providerId,
                null,
                sessionTime,
                60,
                "First session on tennis drills"
        );

        mockMvc.perform(post("/v1/bookings")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + studentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.userId").value(studentUserId))
                .andExpect(jsonPath("$.providerId").value(providerId))
                .andExpect(jsonPath("$.providerName").value("Elite Coach Academy"))
                .andExpect(jsonPath("$.durationMinutes").value(60))
                .andExpect(jsonPath("$.status").value("CONFIRMED"))
                .andExpect(jsonPath("$.notes").value("First session on tennis drills"));
    }

    @Test
    void createBooking_Unauthorized_Returns401() throws Exception {
        Instant sessionTime = Instant.now().plus(1, ChronoUnit.DAYS);
        CreateBookingRequest request = new CreateBookingRequest(providerId, null, sessionTime, 60, "No auth");

        mockMvc.perform(post("/v1/bookings")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void createBooking_PastSessionTime_Returns400() throws Exception {
        Instant pastTime = Instant.now().minus(1, ChronoUnit.DAYS);
        CreateBookingRequest request = new CreateBookingRequest(providerId, null, pastTime, 60, "Past time");

        mockMvc.perform(post("/v1/bookings")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + studentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void createBooking_Conflict_Returns409() throws Exception {
        Instant sessionTime = Instant.now().plus(3, ChronoUnit.DAYS).truncatedTo(ChronoUnit.SECONDS);
        CreateBookingRequest req1 = new CreateBookingRequest(providerId, null, sessionTime, 60, "First");

        mockMvc.perform(post("/v1/bookings")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + studentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req1)))
                .andExpect(status().isCreated());

        // Attempt overlapping booking at 30 minutes in
        CreateBookingRequest req2 = new CreateBookingRequest(
                providerId,
                null,
                sessionTime.plus(30, ChronoUnit.MINUTES),
                60,
                "Overlap"
        );

        mockMvc.perform(post("/v1/bookings")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + otherStudentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req2)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message", containsString("already booked")));
    }

    @Test
    void getUserBookings_ReturnsOnlyUserBookings() throws Exception {
        Instant time1 = Instant.now().plus(2, ChronoUnit.DAYS).truncatedTo(ChronoUnit.SECONDS);
        Instant time2 = Instant.now().plus(4, ChronoUnit.DAYS).truncatedTo(ChronoUnit.SECONDS);

        // Student 1 booking
        mockMvc.perform(post("/v1/bookings")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + studentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new CreateBookingRequest(providerId, null, time1, 60, "Alice"))))
                .andExpect(status().isCreated());

        // Student 2 booking
        mockMvc.perform(post("/v1/bookings")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + otherStudentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new CreateBookingRequest(providerId, null, time2, 60, "Bob"))))
                .andExpect(status().isCreated());

        // Student 1 checks my bookings
        mockMvc.perform(get("/v1/bookings/me")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", hasSize(1)))
                .andExpect(jsonPath("$.content[0].notes").value("Alice"))
                .andExpect(jsonPath("$.content[0].userId").value(studentUserId));
    }

    @Test
    void cancelBooking_Success() throws Exception {
        Instant sessionTime = Instant.now().plus(2, ChronoUnit.DAYS).truncatedTo(ChronoUnit.SECONDS);
        MvcResult result = mockMvc.perform(post("/v1/bookings")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + studentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new CreateBookingRequest(providerId, null, sessionTime, 60, "To Cancel"))))
                .andExpect(status().isCreated())
                .andReturn();

        String responseStr = result.getResponse().getContentAsString();
        Long bookingId = objectMapper.readTree(responseStr).get("id").asLong();

        mockMvc.perform(patch("/v1/bookings/" + bookingId + "/cancel")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELLED"));
    }

    @Test
    void cancelBooking_OtherUser_Returns403() throws Exception {
        Instant sessionTime = Instant.now().plus(2, ChronoUnit.DAYS).truncatedTo(ChronoUnit.SECONDS);
        MvcResult result = mockMvc.perform(post("/v1/bookings")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + studentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new CreateBookingRequest(providerId, null, sessionTime, 60, "Alice's booking"))))
                .andExpect(status().isCreated())
                .andReturn();

        Long bookingId = objectMapper.readTree(result.getResponse().getContentAsString()).get("id").asLong();

        // Student 2 attempts to cancel Student 1's booking
        mockMvc.perform(patch("/v1/bookings/" + bookingId + "/cancel")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + otherStudentToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", containsString("permission")));
    }
}
