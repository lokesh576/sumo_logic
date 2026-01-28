# Platform Monitoring & Automation – Take-Home Assignment

This repository contains my solution for the PacerPro Platform Engineer take-home assignment.
The objective is to detect slow API responses, trigger automated remediation, and provision
the required AWS infrastructure using Infrastructure as Code.

---

## Time Estimate
- Total time spent: ~3 hours
- The exercise exceeded the suggested 55 minutes to allow for testing, validation,
  and clear documentation.

---

## Repository Structure

```
.
├── sumo_logic_query.txt        # Sumo Logic query for slow /api/data responses
├── lambda_function/            # Python AWS Lambda code
├── terraform/                  # Terraform IaC (EC2, Lambda, SNS, IAM)
├── recordings/                 # Links to screen + audio recordings
└── README.md
```
---

## Part 1: Sumo Logic Query & Alert
- Identifies `/api/data` requests with response time greater than **3000 ms**
- Alert triggers when **more than 5 events occur within a 10-minute window**
- Alert is configured to invoke an AWS Lambda function


---

## Part 2: AWS Lambda Function
- Triggered by the Sumo Logic alert
- Performs the following actions:
  - Restarts a specified EC2 instance
  - Logs actions to CloudWatch
  - Sends a notification to an SNS topic
- Implemented using Python


---

## Part 3: Infrastructure as Code (Terraform)
- Provisions the following resources:
  - EC2 instance
  - AWS Lambda function
  - SNS topic and subscription
  - IAM roles and policies
- IAM permissions follow the principle of least privilege

📹 Screen & audio recording:  
[(https://drive.google.com/file/d/1L82mZZrSf78R2oQoHtl5LX5vBY7HRpWH/view?usp=sharing)]

---

## Assumptions & Notes
- A single EC2 instance is restarted for simplicity.
- Restarting the instance is used as a basic remediation strategy.
- Sumo Logic → Lambda integration assumes a webhook-based trigger.
- The solution prioritizes clarity, correctness, and production-oriented design.

---

## Future Improvements
- **Branching & Deployment Strategies**
  - Introduce environment-based deployments (dev/stage/prod) using Terraform workspaces or separate state backends.
  - Enable blue/green or canary-style deployments for safer infrastructure and Lambda updates.

- **Stricter IAM Policies**
  - Further tighten IAM permissions by scoping EC2 actions to specific instance ARNs or tags.
  - Separate execution roles for Lambda, Terraform, and CI/CD to reduce blast radius.

- **CI/CD Automation**
  - Integrate GitHub with AWS CodePipeline for automated builds and deployments.
  - Trigger Terraform plan/apply and Lambda packaging on pull requests and merges.
  - Add basic validation steps (terraform fmt, terraform validate, unit tests).

- **Resilience & Observability**
  - Extend remediation beyond restarts (e.g., alarms, scaling, or automated rollbacks).
  - Add structured logging and metrics for better visibility into alert frequency and recovery actions.
