package com.coachfinder.coachfinder_backend.activity;

import com.coachfinder.coachfinder_backend.BaseIT;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class ActivityApiIT extends BaseIT {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void getAllActivities_ReturnsSeededActivities() throws Exception {
        mockMvc.perform(get("/v1/activities"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(8)))
                .andExpect(jsonPath("$[?(@.name == 'Cricket')]").exists())
                .andExpect(jsonPath("$[?(@.name == 'Badminton')]").exists())
                .andExpect(jsonPath("$[?(@.name == 'Swimming')]").exists())
                .andExpect(jsonPath("$[?(@.name == 'Guitar')]").exists())
                .andExpect(jsonPath("$[?(@.name == 'Chess')]").exists())
                .andExpect(jsonPath("$[?(@.name == 'Yoga')]").exists())
                .andExpect(jsonPath("$[?(@.name == 'Football')]").exists())
                .andExpect(jsonPath("$[?(@.name == 'Tennis')]").exists());
    }
}
