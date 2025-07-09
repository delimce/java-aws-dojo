package com.delimce.aws.dojo.infrastructure.exception;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class InfrastructureException extends RuntimeException {
    
    private static final Logger log = LoggerFactory.getLogger(InfrastructureException.class);
    
    public InfrastructureException(String message) {
        super(message);
        log.error("Infrastructure error: {}", message);
    }
    
    public InfrastructureException(String message, Throwable cause) {
        super(message, cause);
        log.error("Infrastructure error: {}", message, cause);
    }
    
    public InfrastructureException(Throwable cause) {
        super(cause);
        log.error("Infrastructure error occurred", cause);
    }
}
