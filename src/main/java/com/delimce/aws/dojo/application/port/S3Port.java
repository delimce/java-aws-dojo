package com.delimce.aws.dojo.application.port;

public interface S3Port {

    public String uploadFile(String bucketName, String fileName, byte[] fileContent);

    public byte[] downloadFile(String bucketName, String fileName);

    public void deleteFile(String bucketName, String fileName);

}
