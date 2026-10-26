package com.coachfinder.coachfinder_backend.booking.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;

public record CreateBookingRequest(
        @NotNull(message = "Provider ID is required")
        Long providerId,

        Long activityId,

        @NotNull(message = "Session time is required")
        @Future(message = "Session time must be in the future")
        Instant sessionTime,

        Integer durationMinutes,

        String notes
) {
}
