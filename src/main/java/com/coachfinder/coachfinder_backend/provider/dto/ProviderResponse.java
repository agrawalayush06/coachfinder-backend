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
    private Double distanceKm;
    private Instant createdAt;
    private Instant updatedAt;

    public ProviderResponse() {
    }

    public ProviderResponse(Long id, Long userId, String type, String name, String city, Double lat, Double lng, Instant createdAt, Instant updatedAt) {
        this(id, userId, type, name, city, lat, lng, null, createdAt, updatedAt);
    }

    public ProviderResponse(Long id, Long userId, String type, String name, String city, Double lat, Double lng, Double distanceKm, Instant createdAt, Instant updatedAt) {
        this.id = id;
        this.userId = userId;
        this.type = type;
        this.name = name;
        this.city = city;
        this.lat = lat;
        this.lng = lng;
        this.distanceKm = distanceKm;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public static ProviderResponse fromEntity(Provider provider) {
        return fromEntity(provider, null);
    }

    public static ProviderResponse fromEntity(Provider provider, Double distanceKm) {
        return new ProviderResponse(
                provider.getId(),
                provider.getUserId(),
                provider.getType(),
                provider.getName(),
                provider.getCity(),
                provider.getLat(),
                provider.getLng(),
                distanceKm,
                provider.getCreatedAt(),
                provider.getUpdatedAt()
        );
    }

    public static ProviderResponse fromProjection(ProviderWithDistanceProjection projection) {
        Double distance = projection.getDistanceKm();
        if (distance != null) {
            distance = Math.round(distance * 100.0) / 100.0;
        }
        return new ProviderResponse(
                projection.getId(),
                projection.getUserId(),
                projection.getType(),
                projection.getName(),
                projection.getCity(),
                projection.getLat(),
                projection.getLng(),
                distance,
                projection.getCreatedAt(),
                projection.getUpdatedAt()
        );
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public Double getLat() {
        return lat;
    }

    public void setLat(Double lat) {
        this.lat = lat;
    }

    public Double getLng() {
        return lng;
    }

    public void setLng(Double lng) {
        this.lng = lng;
    }

    public Double getDistanceKm() {
        return distanceKm;
    }

    public void setDistanceKm(Double distanceKm) {
        this.distanceKm = distanceKm;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
