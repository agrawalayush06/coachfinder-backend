package com.coachfinder.coachfinder_backend.booking;

import com.coachfinder.coachfinder_backend.activity.Activity;
import com.coachfinder.coachfinder_backend.activity.ActivityRepository;
import com.coachfinder.coachfinder_backend.booking.dto.BookingResponse;
import com.coachfinder.coachfinder_backend.booking.dto.CreateBookingRequest;
import com.coachfinder.coachfinder_backend.common.exception.ConflictException;
import com.coachfinder.coachfinder_backend.common.exception.ForbiddenException;
import com.coachfinder.coachfinder_backend.common.exception.ResourceNotFoundException;
import com.coachfinder.coachfinder_backend.provider.Provider;
import com.coachfinder.coachfinder_backend.provider.ProviderRepository;
import com.coachfinder.coachfinder_backend.user.AppUser;
import com.coachfinder.coachfinder_backend.user.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@Transactional
public class BookingService {

    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final ProviderRepository providerRepository;
    private final ActivityRepository activityRepository;

    public BookingService(
            BookingRepository bookingRepository,
            UserRepository userRepository,
            ProviderRepository providerRepository,
            ActivityRepository activityRepository
    ) {
        this.bookingRepository = bookingRepository;
        this.userRepository = userRepository;
        this.providerRepository = providerRepository;
        this.activityRepository = activityRepository;
    }

    public BookingResponse createBooking(Long userId, CreateBookingRequest req) {
        if (req.sessionTime() == null || req.sessionTime().isBefore(Instant.now())) {
            throw new IllegalArgumentException("Session time must be in the future");
        }

        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id " + userId));

        Provider provider = providerRepository.findById(req.providerId())
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found with id " + req.providerId()));

        Activity activity = null;
        if (req.activityId() != null) {
            activity = activityRepository.findById(req.activityId())
                    .orElseThrow(() -> new ResourceNotFoundException("Activity not found with id " + req.activityId()));
        }

        int duration = (req.durationMinutes() != null && req.durationMinutes() > 0) ? req.durationMinutes() : 60;
        Instant newStart = req.sessionTime();
        Instant newEnd = newStart.plus(duration, ChronoUnit.MINUTES);

        // Check for conflicting bookings for this provider
        Instant searchStart = newStart.minus(4, ChronoUnit.HOURS);
        Instant searchEnd = newEnd.plus(4, ChronoUnit.HOURS);
        List<Booking> candidates = bookingRepository.findPotentialOverlaps(
                provider.getId(),
                BookingStatus.CANCELLED,
                searchStart,
                searchEnd
        );

        for (Booking existing : candidates) {
            Instant existingStart = existing.getSessionTime();
            Instant existingEnd = existingStart.plus(existing.getDurationMinutes(), ChronoUnit.MINUTES);
            if (newStart.isBefore(existingEnd) && existingStart.isBefore(newEnd)) {
                throw new ConflictException("Provider is already booked for this time slot (" + existingStart + " to " + existingEnd + ")");
            }
        }

        Booking booking = new Booking(
                user,
                provider,
                activity,
                newStart,
                duration,
                BookingStatus.CONFIRMED,
                req.notes()
        );

        Booking saved = bookingRepository.save(booking);
        return BookingResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public Page<BookingResponse> getUserBookings(Long userId, Pageable pageable) {
        return bookingRepository.findByUserId(userId, pageable)
                .map(BookingResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public BookingResponse getBookingById(Long bookingId, Long userId, String userRole) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with id " + bookingId));

        boolean isAdmin = "ADMIN".equalsIgnoreCase(userRole);
        if (!booking.getUser().getId().equals(userId) && !isAdmin) {
            throw new ForbiddenException("You do not have permission to view this booking");
        }

        return BookingResponse.fromEntity(booking);
    }

    public BookingResponse cancelBooking(Long bookingId, Long userId, String userRole) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with id " + bookingId));

        boolean isAdmin = "ADMIN".equalsIgnoreCase(userRole);
        if (!booking.getUser().getId().equals(userId) && !isAdmin) {
            throw new ForbiddenException("You do not have permission to cancel this booking");
        }

        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new IllegalArgumentException("Booking is already cancelled");
        }

        booking.setStatus(BookingStatus.CANCELLED);
        Booking updated = bookingRepository.save(booking);
        return BookingResponse.fromEntity(updated);
    }
}
