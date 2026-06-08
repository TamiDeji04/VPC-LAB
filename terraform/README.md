# Terraform Version (In Progress)

This directory will contain the Terraform version of the AWS VPC Architecture Lab.

The goal is to replace all manual console steps with Infrastructure as Code, making the entire lab reproducible with a single `terraform apply` command.

## Planned Resources

```hcl
# VPC
resource "aws_vpc" "tami_cloud" {}

# Subnets
resource "aws_subnet" "public" {}
resource "aws_subnet" "private" {}

# Internet Gateway
resource "aws_internet_gateway" "tami_cloud_gw" {}

# Route Tables
resource "aws_route_table" "public" {}
resource "aws_route_table" "private" {}

# Route Table Associations
resource "aws_route_table_association" "public" {}
resource "aws_route_table_association" "private" {}

# Security Group
resource "aws_security_group" "tami_security" {}

# IAM Role and Instance Profile
resource "aws_iam_role" "ec2_ssm_role" {}
resource "aws_iam_instance_profile" "ec2_ssm_profile" {}

# EC2 Instance
resource "aws_instance" "tami_ec2_server" {}
```

## Status

Console version: Complete and verified (SSM connected)  
Terraform version: In progress
