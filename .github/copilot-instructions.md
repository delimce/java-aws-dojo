<!-- Copilot / AI coding assistant guidance for the java-aws-dojo repository -->
# Quick orientation

This is a small Spring Boot project that follows a lightweight hexagonal (ports & adapters) architecture intended for experimenting with AWS services via LocalStack.

Top-level locations to know:
- `src/main/java/com/delimce/aws/dojo/configuration` — application configuration (e.g. `AwsConfig`).
- `src/main/java/com/delimce/aws/dojo/application/port` — input/output ports (e.g. `S3Port`).
- `src/main/java/com/delimce/aws/dojo/application/service` — use-case services (e.g. `UploadFileService`).
- `src/main/java/com/delimce/aws/dojo/infrastructure/out/adapter` — adapters that implement output ports (e.g. `S3Adapter`).
- `src/main/java/com/delimce/aws/dojo/infrastructure/in/command` — CLI-style commands built on `CommandLineRunner` (`BaseCommand`, `S3UploadCommand`).

# What the project is for (big picture)
- Purpose: provide an experiment playground to integrate AWS SDK (S3, EventBridge, RDS) with a Java Spring Boot app while using LocalStack for local development.
- Primary flows: application services call defined ports (interfaces) and rely on adapters in `infrastructure/out/adapter` for concrete AWS or mocked behavior.
- Example: `UploadFileService` depends on `S3Port` → implemented by `S3Adapter`. CLI command `S3UploadCommand` uses `UploadFileService` to exercise the flow.

# Developer workflows & useful commands
- Common local setup is driven by the repository Makefile and LocalStack. See `README.md` for high-level steps.
- Key commands you may propose in patches or use in examples:
  - make init        (prepare directories & start containers)
  - make start       (start localstack & services)
  - make setup       (configure AWS CLI and create resources in LocalStack)
  - make health-check (verify LocalStack running; also: curl http://localhost:4566/_localstack/health)
  - mvn -DskipTests=true spring-boot:run  (run the app without running tests)
  - mvn test         (run unit tests)

# Project-specific conventions and patterns
- Hexagonal architecture: never call infrastructure classes directly from application services — use the port interfaces in `application/port`.
- Adapters live in `infrastructure/out/adapter` and are annotated with Spring stereotypes (e.g. `@Component`) so DI will wire them to ports.
- Simple CLI commands derive from `BaseCommand` (which implements `CommandLineRunner`). They accept raw `String... args`; examples: `S3UploadCommand`.
- Configuration values are resolved from `src/main/resources/application-*.yml` and can be overridden by environment variables. Common properties:
  - `spring.cloud.aws.region.static` (see `AwsConfig`)
  - LocalStack endpoints: `AWS_ENDPOINT_URI` / `AWS_S3_ENDPOINT_URI` default to `http://localhost:4566` in `application-dev.yml`.

# Integration points / external deps to be mindful of
- LocalStack (http://localhost:4566) — this repo expects LocalStack for all AWS interactions during dev.
- PostgreSQL, MongoDB, Redis containers are defined/used by the compose/Makefile flows — check `docker-compose.yml` and `Makefile` if you need to change service names, ports or credentials.
- AWS SDK v2 is used (see `pom.xml` for `s3`, `eventbridge`, `rds`), and Spring Cloud AWS starter is present. Keep changes compatible with those versions.

# Examples of patterns to follow when making changes
- Add a new outbound integration: create a port in `application/port`, implement it in `infrastructure/out/adapter`, annotate the adapter with `@Component`, and update/consume the port from an `application/service` class.
- Add a new CLI command: extend `BaseCommand`, add a constructor that wires needed services, and register it as a Spring bean (`@Component`). Keep argument parsing minimal and document usage in the `run` method.

# Files to reference in PRs or when suggesting edits
- `README.md` — environment & Makefile commands.
- `pom.xml` — Java version and dependencies (OpenJDK 21, Spring Boot 3.5.7).
- `src/main/resources/application-dev.yml` — LocalStack configuration defaults and property names.
- `src/main/java/com/delimce/aws/dojo/application/port/S3Port.java` — port contract example.
- `src/main/java/com/delimce/aws/dojo/infrastructure/out/adapter/S3Adapter.java` — adapter example.
- `src/main/java/com/delimce/aws/dojo/infrastructure/in/command/S3UploadCommand.java` — CLI example.

# Tone & constraints for code suggestions
- Keep changes minimal and isolated; respect hexagonal boundaries.
- Avoid introducing heavy new dependencies. If a dependency is needed, note it explicitly and add it to `pom.xml` with a short rationale.
- Provide runnable examples and update `README.md` or add a short README snippet when you add commands or local environment expectations.

If any examples above are incomplete or you'd like me to expand specific sections (e.g., adding a guide for testing adapters with LocalStack), tell me which area to expand.

# AWS DocumentDB service will be simulated using the existing MongoDB container defined in the `docker-compose.yml` file.

- DocumentDB is compatible with MongoDB APIs, so the MongoDB container can be used to mimic DocumentDB behavior for local development and testing purposes.

# AWS Elasticache service will be simulated using the existing Redis container defined in the `docker-compose.yml` file.

- ElastiCache is compatible with Redis APIs, so the Redis container can be used to mimic ElastiCache behavior for local development and testing purposes.

# AWS RDS Aurora service will be simulated using the existing PostgreSQL container defined in the `docker-compose.yml` file.

- Aurora is compatible with PostgreSQL APIs, so the PostgreSQL container can be used to mimic Aurora behavior for local development and testing purposes.
