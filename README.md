# Coach Finder Backend

Coach Finder is a discovery platform connecting users with sports coaches, academies, classes, workshops, and competitions.
Users discover providers based on activity type, city location, skill level, budget, and personal preferences.
This repository houses the backend REST APIs built as a clean Modular Monolith targeting production-grade standards.

## Tech Stack
- **Language & Runtime**: Java 25
- **Framework**: Spring Boot 4 (Spring Web, Spring Data JPA, Validation, Actuator)
- **Database**: PostgreSQL 16
- **Schema Management**: Flyway Database Migrations
- **Testing**: JUnit 5, Mockito, Spring Boot Test, Testcontainers
- **Build Tool**: Maven Wrapper (`./mvnw`)

## Prerequisites
- JDK 25 (e.g., Eclipse Temurin JDK 25)
- Docker Desktop (for running PostgreSQL and integration tests)

## How to Run Locally

1. **Start PostgreSQL Container**:
   ```bash
   docker compose up -d
   ```

2. **Start Spring Boot Application**:
   ```bash
   ./mvnw spring-boot:run
   ```

3. **Verify Health Check**:
   - URL: [http://localhost:8080/actuator/health](http://localhost:8080/actuator/health)
   - Response: `{"status":"UP"}`

## Target Endpoints & Example cURL Commands

| HTTP Method | Endpoint | Status Code | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/v1/users` | `201 Created` | Create a new user (role `COACH`, `USER`, or `STUDENT`) |
| `GET` | `/v1/users/{id}` | `200 OK` / `404` | Get user details by ID |
| `GET` | `/v1/activities` | `200 OK` | Get all seeded activities (Cricket, Badminton, Yoga, etc.) |
| `POST` | `/v1/providers` | `201 Created` | Register a new provider |
| `GET` | `/v1/providers/{id}` | `200 OK` / `404` | Get provider by ID |
| `GET` | `/v1/providers` | `200 OK` | Search providers by `city` and/or `activityId` (paginated) |
| `PUT` | `/v1/providers/{id}` | `200 OK` | Update provider details |
| `DELETE` | `/v1/providers/{id}` | `204 No Content` | Delete provider by ID |

### cURL Examples

- **Create User**:
  ```bash
  curl -X POST http://localhost:8080/v1/users \
    -H "Content-Type: application/json" \
    -d '{"email": "alex@example.com", "name": "Alex Smith", "role": "COACH"}'
  ```

- **Get User by ID**:
  ```bash
  curl http://localhost:8080/v1/users/1
  ```

- **List Activities**:
  ```bash
  curl http://localhost:8080/v1/activities
  ```

- **Create Provider**:
  ```bash
  curl -X POST http://localhost:8080/v1/providers \
    -H "Content-Type: application/json" \
    -d '{"userId": 1, "type": "INDIVIDUAL", "name": "Alex Tennis Coaching", "city": "Delhi", "lat": 28.61, "lng": 77.20}'
  ```

- **Get Provider by ID**:
  ```bash
  curl http://localhost:8080/v1/providers/1
  ```

- **Search Providers by City**:
  ```bash
  curl "http://localhost:8080/v1/providers?city=Delhi&page=0&size=10"
  ```

- **Update Provider**:
  ```bash
  curl -X PUT http://localhost:8080/v1/providers/1 \
    -H "Content-Type: application/json" \
    -d '{"type": "ACADEMY", "name": "Alex Elite Tennis Academy", "city": "Delhi", "lat": 28.61, "lng": 77.20}'
  ```

- **Delete Provider**:
  ```bash
  curl -X DELETE http://localhost:8080/v1/providers/1
  ```

## How to Run Tests

Run the full automated unit and integration test suite:
```bash
./mvnw test
```

## Package Structure & Module Rules

All application code lives strictly under `com.coachfinder.coachfinder_backend`:
- `provider`: Provider entity, repository, service, DTOs, and REST controller.
- `activity`: Activity entity, repository, service, DTOs, and REST controller.
- `user`: AppUser entity, repository, service, DTOs, and REST controller.
- `common.exception`: Global exception handler (`@RestControllerAdvice`), `ResourceNotFoundException`, `ConflictException`, and standard error DTOs.

### Core Architectural Principle
Each module strictly owns its database tables and repository interfaces. **Modules never touch another module's repository directly.** Inter-module operations must call the target module's service method (e.g., `ProviderService` calls `UserService.existsById(userId)`).

## Roadmap
- **Phase 1: Backend foundation (CURRENT)**
- Phase 2: iOS app + MapKit
- Phase 3: Auth (OAuth2/OIDC + JWT, RBAC)
- Phase 4: Search + geo
- Phase 5: Booking + payments
- Phase 6: Docker + AWS deploy
- Phase 7: Redis, Kafka, observability
