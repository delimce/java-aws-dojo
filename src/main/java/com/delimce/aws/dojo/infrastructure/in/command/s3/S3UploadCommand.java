package com.delimce.aws.dojo.infrastructure.in.command.s3;

import org.springframework.shell.standard.ShellMethod;
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
    @ShellMethod(key = "s3-upload", value = "Upload a file to S3 bucket")
    public String execute(String... args) {
        return "Please provide the necessary options to upload a file.";
    }

    
}
