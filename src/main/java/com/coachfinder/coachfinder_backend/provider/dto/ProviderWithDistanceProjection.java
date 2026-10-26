package com.coachfinder.coachfinder_backend.provider.dto;

import java.time.Instant;

public interface ProviderWithDistanceProjection {
    Long getId();
    Long getUserId();
    String getType();
    String getName();
    String getCity();
    Double getLat();
    Double getLng();
    Instant getCreatedAt();
    Instant getUpdatedAt();
    Double getDistanceKm();
}
