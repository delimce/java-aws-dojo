# java-aws-dojo
The best spot 2 practice the ancient and mysterious arts of AWS with Java + springboot framework.

## LocalStack Development Environment

This project uses LocalStack to simulate AWS services locally for development and testing purposes.

### Prerequisites

- Docker and Docker Compose
- AWS CLI
- Make
- Terraform
- OpenJdk >= 17
- Maven

### Using the Makefile

The Makefile provides commands to manage your local development environment:

```bash
# Initialize the entire environment (prepare directories, start containers, configure AWS CLI, NO infra deployed)
make init

# View all available commands
make help

# Individual commands
make prepare             # Create necessary directories
make start               # Start all containers
make setup               # Setup AWS resources in LocalStack
make stop                # Stop all containers
make clean               # Remove containers, volumes, and directories
make status              # Check container status
make health-check        # Verify LocalStack health
make terraform-init      # Initialize Terraform configuration
make terraform-plan      # Preview Terraform changes
make terraform-apply     # Apply Terraform changes
make terraform-destroy   # Destroy Terraform-managed infrastructure
```

### Available Services
```

### Available Services

The LocalStack environment includes the following AWS services:
- SQS (Simple Queue Service)
- SNS (Simple Notification Service)
- EC2 (Basic functionality)
- RDS (Simulated with PostgreSQL)
- S3 (Simple Storage Service)
- EventBridge

### AWS Configuration for Local Development

When working with the LocalStack environment:
- Endpoint URL: http://localhost:4566
- Region: eu-west-1
- Access Key: test
- Secret Key: test

For more details, check the `docker-compose.yml` and `Makefile`.
```
## File structure

 This structure is lightweight but follows the hexagonal architecture principles and is extensible.

```
src/main/java/
├── configuration/                # Application-wide configuration classes
│   └── SecurityConfiguration.java
├── domain/
│   ├── model/
│   ├── service/
│   ├── event/
│   └── port/
├── application/
│   ├── service/
│   └── port/
│       ├── in/
│       └── out/
└── infrastructure/
    ├── in/
    │   ├── controller/
    │   │   ├── dto/
    │   │   └── mapper/
    │   └── listener/
    ├── out/
    │   ├── repository/
    │   │   ├── entity/
    │   │   └── mapper/
    │   ├── notification/
    │   └── client/

  ```
 on the **Hexagonal Architecture**, here's a lightweight, extensible file structure for your application:

### Simplified File Structure
```bash
src/main/java/
├── domain/                       # Pure business logic
│   ├── model/                    # Entities & Value Objects
│   │   └── Offer.java            # Domain entity with business rules
│   ├── service/                  # Domain services
│   │   └── PricingService.java   # Business logic (e.g., price calculations)
│   └── port/                    # Output ports (interfaces)
│       └── OfferRepository.java  # e.g., interface for persistence
│
├── application/                  # Use cases & orchestration
│   ├── service/                 
│   │   └── OfferService.java     # Use case implementation (e.g., searchOffers)
│   └── port/
│       ├── in/                   # Input ports
│       │   └── SearchUseCase.java
│       └── out/                  # Output ports
│           └── CachePort.java
│
└── infrastructure/               # Adapters & technical implementation
    ├── in/                       # Primary adapters
    │   ├── controller/
    │   │   ├── OfferController.java     # REST endpoint
    │   │   ├── dto/                     # Request/Response objects
    │   │   │   ├── SearchRequest.java
    │   │   │   └── OfferResponse.java
    │   │   └── mapper/
    │   │       └── OfferControllerMapper.java  # DTO ↔ Domain mapper
    │   └── listener/              # e.g., Kafka/RabbitMQ listeners
    │
    └── out/                      # Secondary adapters
        ├── repository/
        │   ├── jpa/              # Database implementation
        │   │   ├── OfferJpaRepository.java
        │   │   └── mapper/
        │   │       └── OfferEntityMapper.java  # Domain ↔ Entity mapper
        │   └── memory/           # Alternative implementation (e.g., for tests)
        │       └── InMemoryOfferRepository.java
        ├── client/               # External APIs
        │   └── FlightProviderClient.java 
        └── cache/                # e.g., Redis adapter
            └── RedisCacheAdapter.java
