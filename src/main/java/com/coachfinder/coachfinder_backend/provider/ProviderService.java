package com.coachfinder.coachfinder_backend.provider;

import com.coachfinder.coachfinder_backend.common.exception.ConflictException;
import com.coachfinder.coachfinder_backend.common.exception.ResourceNotFoundException;
import com.coachfinder.coachfinder_backend.provider.dto.CreateProviderRequest;
import com.coachfinder.coachfinder_backend.provider.dto.ProviderResponse;
import com.coachfinder.coachfinder_backend.provider.dto.UpdateProviderRequest;
import com.coachfinder.coachfinder_backend.user.UserService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class ProviderService {

    private final ProviderRepository providerRepository;
    private final UserService userService;

    public ProviderService(ProviderRepository providerRepository, UserService userService) {
        this.providerRepository = providerRepository;
        this.userService = userService;
    }

    @Transactional
    public ProviderResponse createProvider(CreateProviderRequest request) {
        if (!userService.existsById(request.getUserId())) {
            throw new ResourceNotFoundException("User not found with id: " + request.getUserId());
        }

        if (providerRepository.existsByUserId(request.getUserId())) {
            throw new ConflictException("Provider already exists for user id: " + request.getUserId());
        }

        Provider provider = new Provider();
        provider.setUserId(request.getUserId());
        provider.setType(request.getType());
        provider.setName(request.getName());
        provider.setCity(request.getCity());
        provider.setLat(request.getLat());
        provider.setLng(request.getLng());

        Provider saved = providerRepository.save(provider);
        return ProviderResponse.fromEntity(saved);
    }

    public ProviderResponse getProviderById(Long id) {
        Provider provider = providerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found with id: " + id));
        return ProviderResponse.fromEntity(provider);
    }

    public Page<ProviderResponse> getProviders(String city, Long activityId, Pageable pageable) {
        String filterCity = (city != null && !city.isBlank()) ? city.trim() : null;
        int clampedPageSize = Math.max(1, Math.min(50, pageable.getPageSize()));
        Pageable clampedPageable = PageRequest.of(pageable.getPageNumber(), clampedPageSize, pageable.getSort());
        return providerRepository.findByCityAndActivityId(filterCity, activityId, clampedPageable)
                .map(ProviderResponse::fromEntity);
    }

    @Transactional
    public ProviderResponse updateProvider(Long id, UpdateProviderRequest request) {
        Provider provider = providerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found with id: " + id));

        // userId is explicitly kept unchanged
        provider.setType(request.getType());
        provider.setName(request.getName());
        provider.setCity(request.getCity());
        provider.setLat(request.getLat());
        provider.setLng(request.getLng());

        Provider updated = providerRepository.save(provider);
        return ProviderResponse.fromEntity(updated);
    }

    @Transactional
    public void deleteProvider(Long id) {
        if (!providerRepository.existsById(id)) {
            throw new ResourceNotFoundException("Provider not found with id: " + id);
        }
        providerRepository.deleteById(id);
    }
}
