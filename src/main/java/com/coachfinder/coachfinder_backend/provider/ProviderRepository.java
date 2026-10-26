package com.coachfinder.coachfinder_backend.provider;

import com.coachfinder.coachfinder_backend.provider.dto.ProviderWithDistanceProjection;
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
            WHERE (:city IS NULL OR LOWER(p.city) LIKE LOWER(CONCAT('%', CAST(:city AS text), '%')))
            AND (:activityId IS NULL OR pa.activity_id = :activityId)
            """,
            countQuery = """
            SELECT COUNT(DISTINCT p.id) FROM providers p
            LEFT JOIN provider_activities pa ON p.id = pa.provider_id
            WHERE (:city IS NULL OR LOWER(p.city) LIKE LOWER(CONCAT('%', CAST(:city AS text), '%')))
            AND (:activityId IS NULL OR pa.activity_id = :activityId)
            """,
            nativeQuery = true)
    Page<Provider> findByCityAndActivityId(@Param("city") String city, @Param("activityId") Long activityId, Pageable pageable);

    @Query(value = """
            SELECT 
                p.id AS id,
                p.user_id AS userId,
                p.type AS type,
                p.name AS name,
                p.city AS city,
                p.lat AS lat,
                p.lng AS lng,
                p.created_at AS createdAt,
                p.updated_at AS updatedAt,
                CASE 
                    WHEN CAST(:userLat AS double precision) IS NOT NULL AND CAST(:userLng AS double precision) IS NOT NULL AND p.lat IS NOT NULL AND p.lng IS NOT NULL THEN
                        (6371.0 * acos(least(1.0, greatest(-1.0,
                            cos(radians(CAST(:userLat AS double precision))) * cos(radians(p.lat)) *
                            cos(radians(p.lng) - radians(CAST(:userLng AS double precision))) +
                            sin(radians(CAST(:userLat AS double precision))) * sin(radians(p.lat))
                        ))))
                    ELSE NULL
                END AS distanceKm
            FROM providers p
            LEFT JOIN provider_activities pa ON p.id = pa.provider_id
            WHERE (CAST(:city AS text) IS NULL OR LOWER(p.city) LIKE LOWER(CONCAT('%', CAST(:city AS text), '%')))
              AND (:activityId IS NULL OR pa.activity_id = :activityId)
              AND (CAST(:type AS text) IS NULL OR UPPER(p.type) = UPPER(CAST(:type AS text)))
              AND (
                  CAST(:radiusKm AS double precision) IS NULL OR CAST(:userLat AS double precision) IS NULL OR CAST(:userLng AS double precision) IS NULL OR
                  (p.lat IS NOT NULL AND p.lng IS NOT NULL AND
                   (6371.0 * acos(least(1.0, greatest(-1.0,
                       cos(radians(CAST(:userLat AS double precision))) * cos(radians(p.lat)) *
                       cos(radians(p.lng) - radians(CAST(:userLng AS double precision))) +
                       sin(radians(CAST(:userLat AS double precision))) * sin(radians(p.lat))
                   )))) <= CAST(:radiusKm AS double precision))
              )
            GROUP BY p.id, p.user_id, p.type, p.name, p.city, p.lat, p.lng, p.created_at, p.updated_at
            ORDER BY 
                CASE WHEN CAST(:sortBy AS text) = 'distance' AND CAST(:userLat AS double precision) IS NOT NULL AND CAST(:userLng AS double precision) IS NOT NULL THEN
                    CASE WHEN p.lat IS NOT NULL AND p.lng IS NOT NULL THEN
                        (6371.0 * acos(least(1.0, greatest(-1.0,
                            cos(radians(CAST(:userLat AS double precision))) * cos(radians(p.lat)) *
                            cos(radians(p.lng) - radians(CAST(:userLng AS double precision))) +
                            sin(radians(CAST(:userLat AS double precision))) * sin(radians(p.lat))
                        ))))
                    ELSE 999999.0 END
                END ASC,
                CASE WHEN CAST(:sortBy AS text) = 'name' THEN p.name END ASC,
                p.created_at DESC
            """,
            countQuery = """
            SELECT COUNT(DISTINCT p.id) FROM providers p
            LEFT JOIN provider_activities pa ON p.id = pa.provider_id
            WHERE (CAST(:city AS text) IS NULL OR LOWER(p.city) LIKE LOWER(CONCAT('%', CAST(:city AS text), '%')))
              AND (:activityId IS NULL OR pa.activity_id = :activityId)
              AND (CAST(:type AS text) IS NULL OR UPPER(p.type) = UPPER(CAST(:type AS text)))
              AND (
                  CAST(:radiusKm AS double precision) IS NULL OR CAST(:userLat AS double precision) IS NULL OR CAST(:userLng AS double precision) IS NULL OR
                  (p.lat IS NOT NULL AND p.lng IS NOT NULL AND
                   (6371.0 * acos(least(1.0, greatest(-1.0,
                       cos(radians(CAST(:userLat AS double precision))) * cos(radians(p.lat)) *
                       cos(radians(p.lng) - radians(CAST(:userLng AS double precision))) +
                       sin(radians(CAST(:userLat AS double precision))) * sin(radians(p.lat))
                   )))) <= CAST(:radiusKm AS double precision))
              )
            """,
            nativeQuery = true)
    Page<ProviderWithDistanceProjection> searchProviders(
            @Param("city") String city,
            @Param("activityId") Long activityId,
            @Param("type") String type,
            @Param("userLat") Double userLat,
            @Param("userLng") Double userLng,
            @Param("radiusKm") Double radiusKm,
            @Param("sortBy") String sortBy,
            Pageable pageable
    );
}
