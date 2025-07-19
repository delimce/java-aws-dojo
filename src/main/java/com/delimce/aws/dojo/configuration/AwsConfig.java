package com.delimce.aws.dojo.configuration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import lombok.Getter;

/**
 * AWS Configuration properties class
 * Demonstrates how to access the environment variables configured in the
 * profiles
 */
@Configuration
@Getter
public class AwsConfig {

    @Value("${spring.cloud.aws.region.static}")
    private String region;
}
