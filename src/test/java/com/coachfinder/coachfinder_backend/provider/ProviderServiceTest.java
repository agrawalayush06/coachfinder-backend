package com.coachfinder.coachfinder_backend.provider;

import com.coachfinder.coachfinder_backend.common.exception.ConflictException;
import com.coachfinder.coachfinder_backend.common.exception.ResourceNotFoundException;
import com.coachfinder.coachfinder_backend.provider.dto.CreateProviderRequest;
import com.coachfinder.coachfinder_backend.provider.dto.ProviderResponse;
import com.coachfinder.coachfinder_backend.provider.dto.UpdateProviderRequest;
import com.coachfinder.coachfinder_backend.user.UserService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProviderServiceTest {

    @Mock
    private ProviderRepository providerRepository;

    @Mock
    private UserService userService;

    @InjectMocks
    private ProviderService providerService;

    @Test
    void createProvider_MissingUser_ThrowsResourceNotFoundException() {
        CreateProviderRequest request = new CreateProviderRequest(99L, "INDIVIDUAL", "John Coaching", "Delhi", null, null);
        when(userService.existsById(99L)).thenReturn(false);

        assertThrows(ResourceNotFoundException.class, () -> providerService.createProvider(request));
        verify(providerRepository, never()).save(any());
    }

    @Test
    void createProvider_DuplicateProviderForUser_ThrowsConflictException() {
        CreateProviderRequest request = new CreateProviderRequest(1L, "INDIVIDUAL", "John Coaching", "Delhi", null, null);
        when(userService.existsById(1L)).thenReturn(true);
        when(providerRepository.existsByUserId(1L)).thenReturn(true);

        assertThrows(ConflictException.class, () -> providerService.createProvider(request));
        verify(providerRepository, never()).save(any());
    }

    @Test
    void getProviders_PageSizeClampedBetween1And50() {
        Pageable largePageable = PageRequest.of(0, 100);
        when(providerRepository.findByCityAndActivityId(eq("Delhi"), eq(null), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of()));

        providerService.getProviders("Delhi", null, largePageable);

        ArgumentCaptor<Pageable> pageableCaptor = ArgumentCaptor.forClass(Pageable.class);
        verify(providerRepository).findByCityAndActivityId(eq("Delhi"), eq(null), pageableCaptor.capture());
        assertEquals(50, pageableCaptor.getValue().getPageSize());
    }

    @Test
    void updateProvider_DoesNotChangeUserId() {
        Provider existingProvider = new Provider();
        existingProvider.setId(10L);
        existingProvider.setUserId(5L);
        existingProvider.setName("Old Name");
        existingProvider.setCity("Mumbai");
        existingProvider.setType("INDIVIDUAL");

        when(providerRepository.findById(10L)).thenReturn(Optional.of(existingProvider));
        when(providerRepository.save(any(Provider.class))).thenAnswer(invocation -> invocation.getArgument(0));

        UpdateProviderRequest updateReq = new UpdateProviderRequest("ACADEMY", "New Academy", "Pune", 18.5, 73.8);
        ProviderResponse response = providerService.updateProvider(10L, updateReq);

        assertEquals(5L, response.getUserId());
        assertEquals("New Academy", response.getName());
    }
}
