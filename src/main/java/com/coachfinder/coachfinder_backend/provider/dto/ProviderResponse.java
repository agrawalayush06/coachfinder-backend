package com.coachfinder.coachfinder_backend.provider.dto;

import com.coachfinder.coachfinder_backend.provider.Provider;
import java.time.Instant;

public class ProviderResponse {

    private Long id;
    private Long userId;
    private String type;
    private String name;
    private String city;
    private Double lat;
    private Double lng;
    private Instant createdAt;
    private Instant updatedAt;

    public ProviderResponse() {
    }

    public ProviderResponse(Long id, Long userId, String type, String name, String city, Double lat, Double lng, Instant createdAt, Instant updatedAt) {
        this.id = id;
        this.userId = userId;
        this.type = type;
        this.name = name;
        this.city = city;
        this.lat = lat;
        this.lng = lng;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public static ProviderResponse fromEntity(Provider provider) {
        return new ProviderResponse(
                provider.getId(),
                provider.getUserId(),
                provider.getType(),
                provider.getName(),
                provider.getCity(),
                provider.getLat(),
                provider.getLng(),
                provider.getCreatedAt(),
                provider.getUpdatedAt()
        );
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public String getType() {
        return type;
    }

    public String getName() {
        return name;
    }

    public String getCity() {
        return city;
    }

    public Double getLat() {
        return lat;
    }

    public Double getLng() {
        return lng;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
