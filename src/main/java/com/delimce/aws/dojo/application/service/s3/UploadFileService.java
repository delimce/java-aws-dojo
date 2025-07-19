package com.delimce.aws.dojo.application.service.s3;

import org.springframework.stereotype.Service;

import com.delimce.aws.dojo.application.port.S3Port;

@Service
public class UploadFileService {

    private final S3Port s3Adapter;

    public UploadFileService(S3Port s3Adapter) {
        this.s3Adapter = s3Adapter;
    }

    public void execute(String bucketName, String fileName, byte[] fileContent) {
        // Call the S3Port to upload the file
        String result = s3Adapter.uploadFile(bucketName, fileName, fileContent);
        System.out.println(result); // Log or handle the result as needed
    }

}
