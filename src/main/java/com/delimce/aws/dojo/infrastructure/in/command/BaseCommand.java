package com.delimce.aws.dojo.infrastructure.in.command;

import org.springframework.shell.standard.ShellComponent;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
@ShellComponent
public abstract class BaseCommand {

    private final String name;
    private final String description;

    public abstract String execute(String... args);

}
