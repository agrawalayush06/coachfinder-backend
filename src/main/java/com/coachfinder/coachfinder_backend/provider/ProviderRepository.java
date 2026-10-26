package com.coachfinder.coachfinder_backend.provider;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProviderRepository extends JpaRepository<Provider, Long> {

    boolean existsByUserId(Long userId);

    @Query(value = """
            SELECT DISTINCT p.* FROM providers p
            LEFT JOIN provider_activities pa ON p.id = pa.provider_id
            WHERE (:city IS NULL OR LOWER(p.city) = LOWER(:city))
            AND (:activityId IS NULL OR pa.activity_id = :activityId)
            """,
            countQuery = """
            SELECT COUNT(DISTINCT p.id) FROM providers p
            LEFT JOIN provider_activities pa ON p.id = pa.provider_id
            WHERE (:city IS NULL OR LOWER(p.city) = LOWER(:city))
            AND (:activityId IS NULL OR pa.activity_id = :activityId)
            """,
            nativeQuery = true)
    Page<Provider> findByCityAndActivityId(@Param("city") String city, @Param("activityId") Long activityId, Pageable pageable);
}
