package com.coachfinder.coachfinder_backend.user.dto;

import com.coachfinder.coachfinder_backend.user.AppUser;
import java.time.Instant;

public class UserResponse {

    private Long id;
    private String email;
    private String name;
    private String role;
    private Instant createdAt;

    public UserResponse() {
    }

    public UserResponse(Long id, String email, String name, String role, Instant createdAt) {
        this.id = id;
        this.email = email;
        this.name = name;
        this.role = role;
        this.createdAt = createdAt;
    }

    public static UserResponse fromEntity(AppUser user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getName(),
                user.getRole(),
                user.getCreatedAt()
        );
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getName() {
        return name;
    }

    public String getRole() {
        return role;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
