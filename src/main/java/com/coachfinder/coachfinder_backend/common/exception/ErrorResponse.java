package com.coachfinder.coachfinder_backend.common.exception;

import java.time.Instant;
import java.util.List;

public class ErrorResponse {

    private Instant timestamp;
    private int status;
    private String message;
    private List<FieldErrorDto> fieldErrors;

    public ErrorResponse() {
    }

    public ErrorResponse(Instant timestamp, int status, String message, List<FieldErrorDto> fieldErrors) {
        this.timestamp = timestamp;
        this.status = status;
        this.message = message;
        this.fieldErrors = fieldErrors;
    }

    public Instant getTimestamp() {
        return timestamp;
    }

    public int getStatus() {
        return status;
    }

    public String getMessage() {
        return message;
    }

    public List<FieldErrorDto> getFieldErrors() {
        return fieldErrors;
    }
}
