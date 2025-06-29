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

### Using the Makefile

The Makefile provides commands to manage your local development environment:

```bash
# Initialize the entire environment (prepare directories, start containers, configure AWS CLI, setup resources)
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
