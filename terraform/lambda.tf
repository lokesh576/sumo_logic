data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda_function.zip"
}

# CloudWatch Log Group with retention
resource "aws_cloudwatch_log_group" "lambda_cloudwatch_log" {
  name              = "/aws/lambda/${aws_lambda_function.pacerpro_lambda.function_name}"
  retention_in_days = 14

  tags = {
    Environment = "production"
    Function    = aws_lambda_function.pacerpro_lambda.function_name
  }
}

# Lambda execution role
resource "aws_iam_role" "demo_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Logs policy
resource "aws_iam_policy" "demo_policy" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:RebootInstances",
          "ec2:DescribeInstances"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/Name" = "${var.application_name}-demo-ec2"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# Attach logging policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.demo_role.name
  policy_arn = aws_iam_policy.demo_policy.arn
}

# Lambda function with logging
resource "aws_lambda_function" "pacerpro_lambda" {
  function_name = "${var.application_name}-sumo-logic-lambda"
  role          = aws_iam_role.demo_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 60

  environment {
    variables = {
      EC2_INSTANCE_ID = aws_instance.pacerpro_ec2_instance.id
      SNS_TOPIC_ARN   = aws_sns_topic.alerts.arn
      REGION          = var.aws_region
    }
  }

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]
}