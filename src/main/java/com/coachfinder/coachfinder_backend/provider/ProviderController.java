package com.coachfinder.coachfinder_backend.provider;

import com.coachfinder.coachfinder_backend.provider.dto.CreateProviderRequest;
import com.coachfinder.coachfinder_backend.provider.dto.ProviderResponse;
import com.coachfinder.coachfinder_backend.provider.dto.UpdateProviderRequest;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/providers")
public class ProviderController {

    private final ProviderService providerService;

    public ProviderController(ProviderService providerService) {
        this.providerService = providerService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProviderResponse createProvider(@Valid @RequestBody CreateProviderRequest request) {
        return providerService.createProvider(request);
    }

    @GetMapping("/{id}")
    public ProviderResponse getProviderById(@PathVariable Long id) {
        return providerService.getProviderById(id);
    }

    @GetMapping
    public Page<ProviderResponse> getProviders(
            @RequestParam(required = false) String city,
            @RequestParam(required = false) Long activityId,
            Pageable pageable) {
        return providerService.getProviders(city, activityId, pageable);
    }

    @PutMapping("/{id}")
    public ProviderResponse updateProvider(
            @PathVariable Long id,
            @Valid @RequestBody UpdateProviderRequest request) {
        return providerService.updateProvider(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteProvider(@PathVariable Long id) {
        providerService.deleteProvider(id);
    }
}
