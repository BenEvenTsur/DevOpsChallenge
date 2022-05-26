# DevOps Challenge

DevOps Challenge is an exercise designed to test DevOps skills using cloud services and IAC tools.
The exercise goal is a deployment of a simple "Hello World" website on AWS. This project suggests a Terraform based solving.

```mermaid
graph LR;
    EC2-1.->Website-1;
    EC2-2.->Website-2;
    ASG-->EC2-1;
    ASG-->EC2-2;
    ALB-->ASG;
```

## Prerequisites

* AWS Account
* AWS CLI installed
* Terraform CLI installed

## Configuration and Initialization

```bash
aws configure
terraform init
```

## Deployment

```bash
terraform apply
```
