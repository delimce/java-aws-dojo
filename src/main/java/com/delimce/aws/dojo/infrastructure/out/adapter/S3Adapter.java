package com.delimce.aws.dojo.infrastructure.out.adapter;

import java.nio.file.Path;

import org.springframework.stereotype.Component;

import com.delimce.aws.dojo.application.port.S3Port;
import com.delimce.aws.dojo.configuration.AwsConfig;
import com.delimce.aws.dojo.infrastructure.exception.InfrastructureException;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectResponse;
import software.amazon.awssdk.services.s3.model.S3Exception;

@Component
public class S3Adapter implements S3Port {

    private final S3Client s3Client;

    public S3Adapter(AwsConfig awsConfig) {
        this.s3Client = S3Client.builder()
                .region(Region.of(awsConfig.getRegion()))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(
                                awsConfig.getAccessKeyId(),
                                awsConfig.getSecretAccessKey())))
                .build();
    }

    @Override
    public String uploadFile(String bucketName, String fileName, Path filePath) {
        try {
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(fileName)
                    .build();

            PutObjectResponse response = s3Client.putObject(
                    putObjectRequest,
                    RequestBody.fromFile(filePath));

            return String.format("File '%s' uploaded successfully to bucket '%s'. ETag: %s",
                    fileName, bucketName, response.eTag());
        } catch (S3Exception e) {
            throw new InfrastructureException("Failed to upload file to S3: " + e.getMessage());
        }
    }

    @Override
    public byte[] downloadFile(String bucketName, String fileName) {
        // Implementation for downloading a file from S3
        return new byte[0]; // Placeholder for actual file content
    }

    @Override
    public void deleteFile(String bucketName, String fileName) {
        // Implementation for deleting a file from S3
    }

    @Override
    public boolean bucketExists(String bucketName) {
        try {
            return s3Client.headBucket(b -> b.bucket(bucketName)).sdkHttpResponse().isSuccessful();
        } catch (S3Exception e) {
            throw new InfrastructureException("Failed to check if bucket exists: " + e.getMessage());
        }
    }
}
