package com.coachfinder.coachfinder_backend.user;

import com.coachfinder.coachfinder_backend.common.exception.ConflictException;
import com.coachfinder.coachfinder_backend.common.exception.ResourceNotFoundException;
import com.coachfinder.coachfinder_backend.user.dto.CreateUserRequest;
import com.coachfinder.coachfinder_backend.user.dto.UserResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        if ("ADMIN".equalsIgnoreCase(request.getRole())) {
            throw new IllegalArgumentException("Role 'ADMIN' is not allowed");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("User with email '" + request.getEmail() + "' already exists");
        }

        AppUser user = new AppUser();
        user.setEmail(request.getEmail());
        user.setName(request.getName());
        user.setRole(request.getRole());

        AppUser saved = userRepository.save(user);
        return UserResponse.fromEntity(saved);
    }

    public UserResponse getUserById(Long id) {
        AppUser user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
        return UserResponse.fromEntity(user);
    }

    public boolean existsById(Long id) {
        return userRepository.existsById(id);
    }
}
