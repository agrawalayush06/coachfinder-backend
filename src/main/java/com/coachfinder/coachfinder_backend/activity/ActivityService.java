package com.coachfinder.coachfinder_backend.activity;

import com.coachfinder.coachfinder_backend.activity.dto.ActivityResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class ActivityService {

    private final ActivityRepository activityRepository;

    public ActivityService(ActivityRepository activityRepository) {
        this.activityRepository = activityRepository;
    }

    public List<ActivityResponse> getAllActivities() {
        return activityRepository.findAll()
                .stream()
                .map(ActivityResponse::fromEntity)
                .toList();
    }
}
