package com.delimce.aws.dojo.application.service.s3;

import org.springframework.stereotype.Service;

import com.delimce.aws.dojo.application.port.S3Port;
import com.delimce.aws.dojo.configuration.AwsConfig;
import com.delimce.aws.dojo.infrastructure.exception.InfrastructureException;

import java.nio.file.Path;

@Service
public class UploadFileService {

    private final S3Port s3Adapter;
    private final AwsConfig awsConfig;

    public UploadFileService(S3Port s3Adapter, AwsConfig awsConfig) {
        this.awsConfig = awsConfig;
        this.s3Adapter = s3Adapter;
    }

    public void execute(String fileName, Path filePath) throws InfrastructureException {

        var bucketName = awsConfig.getS3Bucket(); // set default bucket name from configuration
        if (bucketName == null || bucketName.isEmpty()) {
            throw new IllegalArgumentException("S3 bucket name is not configured.");
        }

        if( !s3Adapter.bucketExists(bucketName) ) {
            throw new InfrastructureException("Bucket does not exist: " + bucketName);
        }

        String result = s3Adapter.uploadFile(bucketName, fileName, filePath);
        System.out.println(result); // Log or handle the result as needed
    }

}
