package com.delimce.aws.dojo.infrastructure.in.command;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.boot.CommandLineRunner;

@Getter
@AllArgsConstructor
public abstract class BaseCommand implements CommandLineRunner {

    private String name;
    private String description;

    @Override
    public abstract void run(String... args);

}
