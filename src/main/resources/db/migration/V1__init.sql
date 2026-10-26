CREATE TABLE users (
                       id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                       email      VARCHAR(255) NOT NULL UNIQUE,
                       name       VARCHAR(120) NOT NULL,
                       role       VARCHAR(20)  NOT NULL,
                       created_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE providers (
                           id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                           user_id    BIGINT       NOT NULL UNIQUE REFERENCES users(id),
                           type       VARCHAR(20)  NOT NULL,
                           name       VARCHAR(150) NOT NULL,
                           city       VARCHAR(100) NOT NULL,
                           lat        DOUBLE PRECISION,
                           lng        DOUBLE PRECISION,
                           created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
                           updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE activities (
                            id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                            name     VARCHAR(100) NOT NULL UNIQUE,
                            category VARCHAR(60)  NOT NULL
);

CREATE TABLE provider_activities (
                                     provider_id       BIGINT       NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
                                     activity_id       BIGINT       NOT NULL REFERENCES activities(id),
                                     skill_level       VARCHAR(20)  NOT NULL,
                                     price_per_session NUMERIC(10,2),
                                     PRIMARY KEY (provider_id, activity_id, skill_level)
);

CREATE INDEX idx_providers_city ON providers(city);