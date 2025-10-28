# AWS LocalStack Development Environment Makefile

.PHONY: help prepare start stop restart setup clean status health-check logs aws-configure terraform-init terraform-plan terraform-apply terraform-destroy

# Default target when running just 'make'
help:
	@echo "AWS LocalStack Development Environment"
	@echo ""
	@echo "Available commands:"
	@echo "  make init           - Fast initialization: prepare, start, and setup"
	@echo "  make prepare        - Create necessary directories for LocalStack"
	@echo "  make maven          - Install Maven Wrapper"
	@echo "  make start          - Start all services defined in docker-compose.yml"
	@echo "  make stop           - Stop all running containers"
	@echo "  make restart        - Restart all services"
	@echo "  make setup          - Setup AWS resources in LocalStack"
	@echo "  make clean          - Remove all containers, volumes, and data directories"
	@echo "  make status         - Show status of all running containers"
	@echo "  make health-check   - Check LocalStack and other services health status"
	@echo "  make logs           - Show logs from all containers"
	@echo "  make aws-configure  - Configure AWS CLI for LocalStack"
	@echo "  make terraform-init - Initialize Terraform in the devops directory"
	@echo "  make terraform-plan - Run Terraform plan against LocalStack"
	@echo "  make terraform-apply - Apply Terraform configuration to LocalStack"
	@echo "  make terraform-destroy - Destroy resources created by Terraform"

# Create the necessary directories for LocalStack
prepare:
	@echo "Creating directories for LocalStack..."
	@mkdir -p localstack-data
	@mkdir -p localstack-tmp
	@chmod -R 777 localstack-data
	@chmod -R 777 localstack-tmp
	@echo "Directories created successfully."

# Start all services
start:
	@echo "Starting containers..."
	@docker compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 5
	@echo "Services started."

# Stop all services
stop:
	@echo "Stopping containers..."
	@docker compose down
	@echo "Containers stopped."

# Restart all services
restart: stop start

# Install Maven Wrapper from CLI.
maven:
	@echo "Installing Maven Wrapper..."
	@mvn wrapper:wrapper
	@echo "Maven Wrapper installed."


# Setup AWS resources in LocalStack
setup:
	@echo "Setting up AWS resources in LocalStack..."
	@echo "Waiting for LocalStack to be ready..."
	@until curl -s http://localhost:4566/_localstack/health | grep -q 'edition:  community'; do \
		echo "Waiting for LocalStack..."; \
		sleep 1; \
	done
	@echo "LocalStack is ready. Setting up resources..."
	@aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name dojo-queue
	@echo "SQS queue created."
	@aws --endpoint-url=http://localhost:4566 sns create-topic --name dojo-topic
	@echo "SNS topic created."
	@aws --endpoint-url=http://localhost:4566 ec2 create-security-group --group-name dojo-sg --description "Dojo Security Group"
	@echo "EC2 security group created."
	@aws --endpoint-url=http://localhost:4566 s3 mb s3://dojo-bucket || true
	@aws --endpoint-url=http://localhost:4566 s3api put-bucket-acl --bucket dojo-bucket --acl public-read || true
	@echo "S3 bucket created."
	@aws --endpoint-url=http://localhost:4566 events put-rule --name dojo-event-rule --schedule-expression 'rate(5 minutes)'
	@echo "EventBridge rule created."
	@QUEUE_URL=$$(aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name dojo-queue --output text); \
	 QUEUE_ARN=$$(aws --endpoint-url=http://localhost:4566 sqs get-queue-attributes --queue-url $$QUEUE_URL --attribute-names QueueArn --output text | awk '{print $$2}'); \
	 aws --endpoint-url=http://localhost:4566 events put-targets --rule dojo-event-rule --targets "Id"="1","Arn"="$$QUEUE_ARN"
	@echo "EventBridge target created."
	@TOPIC_ARN=$$(aws --endpoint-url=http://localhost:4566 sns create-topic --name dojo-topic --output text); \
	 QUEUE_URL=$$(aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name dojo-queue --output text); \
	 QUEUE_ARN=$$(aws --endpoint-url=http://localhost:4566 sqs get-queue-attributes --queue-url $$QUEUE_URL --attribute-names QueueArn --output text | awk '{print $$2}'); \
	 aws --endpoint-url=http://localhost:4566 sns subscribe --topic-arn $$TOPIC_ARN --protocol sqs --notification-endpoint $$QUEUE_ARN
	@echo "SQS subscribed to SNS topic."
	@echo "LocalStack resources setup complete!"

# Remove containers, volumes, and data directories
clean:
	@echo "Cleaning up resources..."
	@docker compose down -v
	@rm -rf localstack-data localstack-tmp
	@echo "Cleanup complete."

# Show status of all running containers
status:
	@docker compose ps

# Check LocalStack health status
health-check:
	@echo "Checking LocalStack health..."
	@echo "\nOverall health status:"
	@curl -s http://localhost:4566/_localstack/health | jq || echo "LocalStack may not be running or 'jq' is not installed."
	@echo "\nServices status:"
	@for service in sqs sns ec2 rds s3 events; do \
		echo "\n$$service status:"; \
		curl -s http://localhost:4566/_localstack/services/$$service | jq || echo "Could not get $$service status"; \
	done

	@echo "\nChecking container health for databases..."

	@echo "\nPostgres (postgres-db):"
	@status=$$(docker inspect --format='{{.State.Health.Status}}' postgres-db 2>/dev/null || true); \
	if [ -n "$$status" ] && [ "$$status" != "null" ]; then \
		echo "Docker health: $$status"; \
	else \
		if command -v nc >/dev/null 2>&1; then \
			if nc -z 127.0.0.1 5432 >/dev/null 2>&1; then \
				echo "postgres reachable on 127.0.0.1:5432 (tcp)"; \
			else \
				echo "postgres NOT reachable on 127.0.0.1:5432"; \
			fi; \
		elif command -v psql >/dev/null 2>&1; then \
			PGPASSWORD=dojo123 psql -h 127.0.0.1 -U dojo -p 5432 -c '\\q' >/dev/null 2>&1 && echo "postgres OK" || echo "postgres check failed"; \
		else \
			echo "No tcp or psql available to check postgres"; \
		fi; \
	fi

	@echo "\nMongoDB (mongo-db):"
	@status=$$(docker inspect --format='{{.State.Health.Status}}' mongo-db 2>/dev/null || true); \
	if [ -n "$$status" ] && [ "$$status" != "null" ]; then \
		echo "Docker health: $$status"; \
	else \
		if command -v nc >/dev/null 2>&1; then \
			if nc -z 127.0.0.1 27017 >/dev/null 2>&1; then \
				echo "mongo reachable on 127.0.0.1:27017 (tcp)"; \
			else \
				echo "mongo NOT reachable on 127.0.0.1:27017"; \
			fi; \
		elif command -v mongosh >/dev/null 2>&1; then \
			mongosh "mongodb://admin:admin123@127.0.0.1:27017/" --eval "db.adminCommand('ping')" >/dev/null 2>&1 && echo "mongo OK" || echo "mongo check failed"; \
		elif command -v mongo >/dev/null 2>&1; then \
			mongo --host 127.0.0.1 --port 27017 --username admin --password admin123 --eval "db.adminCommand('ping')" >/dev/null 2>&1 && echo "mongo OK" || echo "mongo check failed"; \
		else \
			echo "No tcp or mongo client available to check mongo"; \
		fi; \
	fi

	@echo "\nRedis (redis-cache):"
	@status=$$(docker inspect --format='{{.State.Health.Status}}' redis-cache 2>/dev/null || true); \
	if [ -n "$$status" ] && [ "$$status" != "null" ]; then \
		echo "Docker health: $$status"; \
	else \
		if command -v nc >/dev/null 2>&1; then \
			if nc -z 127.0.0.1 6379 >/dev/null 2>&1; then \
				echo "redis reachable on 127.0.0.1:6379 (tcp)"; \
			else \
				echo "redis NOT reachable on 127.0.0.1:6379"; \
			fi; \
		elif command -v redis-cli >/dev/null 2>&1; then \
			redis-cli -h 127.0.0.1 -p 6379 ping >/dev/null 2>&1 && echo "redis OK" || echo "redis check failed"; \
		else \
			echo "No tcp or redis-cli available to check redis"; \
		fi; \
	fi

# Show logs from all containers
logs:
	@docker compose logs

# Configure AWS CLI for LocalStack
aws-configure:
	@echo "Configuring AWS CLI for LocalStack..."
	@aws configure set aws_access_key_id test
	@aws configure set aws_secret_access_key test
	@aws configure set region eu-west-1
	@aws configure set output json
	@echo "AWS CLI configured for LocalStack."

# Terraform operations
terraform-init:
	@echo "Initializing Terraform..."
	@cd devops && terraform init
	@echo "Terraform initialized."

terraform-plan:
	@echo "Running Terraform plan against LocalStack..."
	@cd devops && terraform plan -var="environment=dev" -var="localstack_endpoint=http://localhost:4566"
	@echo "Terraform plan complete."

terraform-apply:
	@echo "Applying Terraform configuration to LocalStack..."
	@cd devops && terraform apply -var="environment=dev" -var="localstack_endpoint=http://localhost:4566" -auto-approve
	@echo "Terraform apply complete."
	@echo "To verify resources, you can use AWS CLI with the LocalStack endpoint:"
	@echo "aws --endpoint-url=http://localhost:4566 <service> <command>"
	@echo "For example, to list S3 buckets: aws --endpoint-url=http://localhost:4566 s3 ls"
	

terraform-destroy:
	@echo "Destroying resources created by Terraform..."
	@cd devops && terraform destroy -var="environment=dev" -var="localstack_endpoint=http://localhost:4566" -auto-approve
	@echo "Terraform destroy complete."

# Init the environment - prepare, start, and setup in one command
init: prepare start aws-configure
	@echo "Environment initialization complete!"
