package com.coachfinder.coachfinder_backend.booking;

import com.coachfinder.coachfinder_backend.booking.dto.BookingResponse;
import com.coachfinder.coachfinder_backend.booking.dto.CreateBookingRequest;
import com.coachfinder.coachfinder_backend.common.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/bookings")
public class BookingController {

    private final BookingService bookingService;

    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @PostMapping
    public ResponseEntity<BookingResponse> createBooking(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateBookingRequest request
    ) {
        BookingResponse response = bookingService.createBooking(principal.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/me")
    public ResponseEntity<Page<BookingResponse>> getMyBookings(
            @AuthenticationPrincipal UserPrincipal principal,
            Pageable pageable
    ) {
        Page<BookingResponse> response = bookingService.getUserBookings(principal.getId(), pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<BookingResponse> getBookingById(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        BookingResponse response = bookingService.getBookingById(id, principal.getId(), principal.getRole());
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/{id}/cancel")
    public ResponseEntity<BookingResponse> cancelBooking(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        BookingResponse response = bookingService.cancelBooking(id, principal.getId(), principal.getRole());
        return ResponseEntity.ok(response);
    }
}
