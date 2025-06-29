# S3 bucket for storage
resource "aws_s3_bucket" "dojo_bucket" {
  bucket = "dojo-bucket"
  force_destroy = true
}

# SNS topic for notifications
resource "aws_sns_topic" "dojo_notifications" {
  name = "dojo-notifications"
}

# SQS queue for message processing
resource "aws_sqs_queue" "dojo_queue" {
  name = "dojo-queue"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 10
}

# Connect the SNS topic to the SQS queue
resource "aws_sns_topic_subscription" "dojo_subscription" {
  topic_arn = aws_sns_topic.dojo_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.dojo_queue.arn
}

# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "dojo_event_rule" {
  name        = "dojo-event-rule"
  description = "Trigger events for the dojo application"
  schedule_expression = "rate(5 minutes)"
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "dojo_event_target" {
  rule      = aws_cloudwatch_event_rule.dojo_event_rule.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.dojo_queue.arn
}

# EC2 Security Group (Note: This is a mock for LocalStack, real EC2 instances aren't created)
resource "aws_security_group" "dojo_sg" {
  name        = "dojo-security-group"
  description = "Security group for dojo application"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output the resource ARNs and IDs for reference in the application
output "s3_bucket_name" {
  value = aws_s3_bucket.dojo_bucket.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.dojo_notifications.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.dojo_queue.id
}
