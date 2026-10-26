package com.coachfinder.coachfinder_backend.auth;

import com.coachfinder.coachfinder_backend.auth.dto.AuthResponse;
import com.coachfinder.coachfinder_backend.auth.dto.LoginRequest;
import com.coachfinder.coachfinder_backend.auth.dto.RegisterRequest;
import com.coachfinder.coachfinder_backend.common.security.UserPrincipal;
import com.coachfinder.coachfinder_backend.user.dto.UserResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @GetMapping("/me")
    public UserResponse getMe(@AuthenticationPrincipal UserPrincipal principal) {
        return authService.getMe(principal.getId());
    }
}
