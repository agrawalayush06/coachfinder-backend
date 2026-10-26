package com.coachfinder.coachfinder_backend.provider.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class UpdateProviderRequest {

    @NotBlank(message = "type is required")
    private String type;

    @NotBlank(message = "name is required")
    @Size(max = 150, message = "name must not exceed 150 characters")
    private String name;

    @NotBlank(message = "city is required")
    @Size(max = 100, message = "city must not exceed 100 characters")
    private String city;

    private Double lat;
    private Double lng;

    public UpdateProviderRequest() {
    }

    public UpdateProviderRequest(String type, String name, String city, Double lat, Double lng) {
        this.type = type;
        this.name = name;
        this.city = city;
        this.lat = lat;
        this.lng = lng;
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
}
