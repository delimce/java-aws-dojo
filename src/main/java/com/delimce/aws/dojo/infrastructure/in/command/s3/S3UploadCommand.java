package com.delimce.aws.dojo.infrastructure.in.command.s3;

import org.springframework.stereotype.Component;

import com.delimce.aws.dojo.application.service.s3.UploadFileService;
import com.delimce.aws.dojo.infrastructure.in.command.BaseCommand;


@Component
public class S3UploadCommand extends BaseCommand {

    private final UploadFileService uploadFileService;

    public S3UploadCommand(UploadFileService uploadFileService) {
        super("s3-upload", "Uploads a file to S3");
        this.uploadFileService = uploadFileService;
    }

    @Override
    public void run(String... args) {
        if (args.length < 3) {
            System.out.println("Usage: s3-upload <bucketName> <fileName> <fileContent>");
            return;
        }

        System.out.println("TESTING S3 UPLOAD COMMAND");

        String bucketName = args[0];
        String fileName = args[1];
        byte[] fileContent = args[2].getBytes(); // Assuming fileContent is passed as a string for simplicity

        uploadFileService.execute(bucketName, fileName, fileContent);
    }

}
