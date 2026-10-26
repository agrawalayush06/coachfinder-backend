package com.coachfinder.coachfinder_backend.auth;

import com.coachfinder.coachfinder_backend.auth.dto.AuthResponse;
import com.coachfinder.coachfinder_backend.auth.dto.LoginRequest;
import com.coachfinder.coachfinder_backend.auth.dto.RegisterRequest;
import com.coachfinder.coachfinder_backend.common.exception.ConflictException;
import com.coachfinder.coachfinder_backend.common.exception.ResourceNotFoundException;
import com.coachfinder.coachfinder_backend.common.security.JwtService;
import com.coachfinder.coachfinder_backend.user.AppUser;
import com.coachfinder.coachfinder_backend.user.UserRepository;
import com.coachfinder.coachfinder_backend.user.dto.UserResponse;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if ("ADMIN".equalsIgnoreCase(request.getRole())) {
            throw new IllegalArgumentException("Role 'ADMIN' is not allowed");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("User with email '" + request.getEmail() + "' already exists");
        }

        AppUser user = new AppUser();
        user.setEmail(request.getEmail());
        user.setName(request.getName());
        user.setRole(request.getRole().toUpperCase());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));

        AppUser savedUser = userRepository.save(user);
        String token = jwtService.generateToken(savedUser.getId(), savedUser.getEmail(), savedUser.getRole());

        return new AuthResponse(token, UserResponse.fromEntity(savedUser));
    }

    public AuthResponse login(LoginRequest request) {
        AppUser user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BadCredentialsException("Invalid email or password"));

        if (user.getPasswordHash() == null || !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid email or password");
        }

        String token = jwtService.generateToken(user.getId(), user.getEmail(), user.getRole());
        return new AuthResponse(token, UserResponse.fromEntity(user));
    }

    public UserResponse getMe(Long userId) {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        return UserResponse.fromEntity(user);
    }
}
