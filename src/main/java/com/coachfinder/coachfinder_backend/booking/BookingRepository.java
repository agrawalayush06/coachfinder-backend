package com.coachfinder.coachfinder_backend.booking;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {

    @Query(
            value = "SELECT b FROM Booking b JOIN FETCH b.provider JOIN FETCH b.user LEFT JOIN FETCH b.activity WHERE b.user.id = :userId ORDER BY b.sessionTime DESC",
            countQuery = "SELECT count(b) FROM Booking b WHERE b.user.id = :userId"
    )
    Page<Booking> findByUserId(@Param("userId") Long userId, Pageable pageable);

    @Query("SELECT b FROM Booking b WHERE b.provider.id = :providerId AND b.status <> :cancelledStatus AND b.sessionTime >= :startWindow AND b.sessionTime <= :endWindow")
    List<Booking> findPotentialOverlaps(
            @Param("providerId") Long providerId,
            @Param("cancelledStatus") BookingStatus cancelledStatus,
            @Param("startWindow") Instant startWindow,
            @Param("endWindow") Instant endWindow
    );
}
