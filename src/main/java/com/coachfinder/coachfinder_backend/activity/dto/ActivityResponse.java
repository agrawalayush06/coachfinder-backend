package com.coachfinder.coachfinder_backend.activity.dto;

import com.coachfinder.coachfinder_backend.activity.Activity;

public class ActivityResponse {

    private Long id;
    private String name;
    private String category;

    public ActivityResponse() {
    }

    public ActivityResponse(Long id, String name, String category) {
        this.id = id;
        this.name = name;
        this.category = category;
    }

    public static ActivityResponse fromEntity(Activity activity) {
        return new ActivityResponse(
                activity.getId(),
                activity.getName(),
                activity.getCategory()
        );
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getCategory() {
        return category;
    }
}
