CREATE TABLE bookings (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id          BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider_id      BIGINT       NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
    activity_id      BIGINT       REFERENCES activities(id) ON DELETE SET NULL,
    session_time     TIMESTAMPTZ  NOT NULL,
    duration_minutes INT          NOT NULL DEFAULT 60,
    status           VARCHAR(30)  NOT NULL DEFAULT 'CONFIRMED',
    notes            TEXT,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_provider_id ON bookings(provider_id);
CREATE INDEX idx_bookings_session_time ON bookings(session_time);
