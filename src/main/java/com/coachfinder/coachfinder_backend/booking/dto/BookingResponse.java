package com.coachfinder.coachfinder_backend.booking.dto;

import com.coachfinder.coachfinder_backend.booking.Booking;
import com.coachfinder.coachfinder_backend.booking.BookingStatus;

import java.time.Instant;

public record BookingResponse(
        Long id,
        Long userId,
        String userName,
        String userEmail,
        Long providerId,
        String providerName,
        String providerType,
        String providerCity,
        Long activityId,
        String activityName,
        Instant sessionTime,
        int durationMinutes,
        BookingStatus status,
        String notes,
        Instant createdAt
) {
    public static BookingResponse fromEntity(Booking booking) {
        return new BookingResponse(
                booking.getId(),
                booking.getUser().getId(),
                booking.getUser().getName(),
                booking.getUser().getEmail(),
                booking.getProvider().getId(),
                booking.getProvider().getName(),
                booking.getProvider().getType(),
                booking.getProvider().getCity(),
                booking.getActivity() != null ? booking.getActivity().getId() : null,
                booking.getActivity() != null ? booking.getActivity().getName() : null,
                booking.getSessionTime(),
                booking.getDurationMinutes(),
                booking.getStatus(),
                booking.getNotes(),
                booking.getCreatedAt()
        );
    }
}
