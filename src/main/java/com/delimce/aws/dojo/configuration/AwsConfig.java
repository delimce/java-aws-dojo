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
@Getter // Lombok annotation for generating getters
public class AwsConfig {

    @Value("${spring.cloud.aws.region.static}")
    private String region;

    @Value("${spring.cloud.aws.credentials.access-key}")
    private String accessKeyId;

    @Value("${spring.cloud.aws.credentials.secret-key}")
    private String secretAccessKey;

    @Value("${app.s3.bucket-name}")
    private String s3Bucket;

}
