# LocalStack-Terraform Setup

This README provides instructions for setting up and using a LocalStack environment with Terraform to simulate AWS cloud resources locally.

## Prerequisites

Ensure you have the following installed:
- Docker
- Docker Compose
- Terraform

## Getting Started

### Step 1: Start LocalStack

Use Docker Compose to launch LocalStack:

```bash
docker-compose up -d
```

This command starts LocalStack in detached mode.

### Step 2:  Terraform

Run the following command to initialize your Terraform workspace, which will download the necessary plugins, Apply your Terraform configuration using mock AWS credentials (since LocalStack doesn't validate them):

```bash
terraform init
AWS_ACCESS_KEY_ID=fake AWS_SECRET_ACCESS_KEY=fake terraform apply
```

This sets the AWS access and secret keys to 'fake' and applies your Terraform configurations to the LocalStack environment.

The `main.tf` in this repository is configured to create an S3 bucket named `devops-360-demo-localstack` and upload the `cat.png` image to it. To view this image, you can access it via the following URL when running LocalStack:

[http://devops-360-demo-localstack.s3.localhost.localstack.cloud:4566/cat.png](http://devops-360-demo-localstack.s3.localhost.localstack.cloud:4566/cat.png)

And you will see this: 

![cat.png](./resources/cat.png)

