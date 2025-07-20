package com.delimce.aws.dojo.application.port;

import java.nio.file.Path;

public interface S3Port {

    public String uploadFile(String bucketName, String fileName, Path filePath);

    public byte[] downloadFile(String bucketName, String fileName);

    public void deleteFile(String bucketName, String fileName);

    public boolean bucketExists(String bucketName);

}
