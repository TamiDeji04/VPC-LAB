# AWS VPC Architecture Lab

A hands-on AWS networking lab built from scratch using the AWS Management Console. Demonstrates core cloud infrastructure skills including VPC design, subnet segmentation, routing, security groups, IAM least-privilege access, and secure instance management via SSM Session Manager with zero open inbound ports.

---

## Architecture Overview

```
                          INTERNET
                              |
                    [Internet Gateway]
                      tami-cloud-gw
                              |
          ┌───────────────────────────────────────┐
          │            tami-cloud VPC              │
          │            10.0.0.0/16                 │
          │            us-east-2 (Ohio)            │
          │                                        │
          │   ┌──────────────────────────────┐     │
          │   │     public-tami-subnet        │     │
          │   │     10.0.1.0/24              │     │
          │   │     us-east-2a               │     │
          │   │                              │     │
          │   │   ┌────────────────────┐     │     │
          │   │   │  tami-ec2-server   │     │     │
          │   │   │  Amazon Linux 2023 │     │     │
          │   │   │  t2.micro          │     │     │
          │   │   │  IAM: ec2-ssm-role │     │     │
          │   │   └────────────────────┘     │     │
          │   │                              │     │
          │   │  tami-public-rt:             │     │
          │   │  0.0.0.0/0  → IGW (internet) │     │
          │   │  10.0.0.0/16 → local         │     │
          │   └──────────────────────────────┘     │
          │                                        │
          │   ┌──────────────────────────────┐     │
          │   │     private-tami-subnet       │     │
          │   │     10.0.2.0/24              │     │
          │   │     (no internet access)     │     │
          │   │                              │     │
          │   │  tami-private-rt:            │     │
          │   │  10.0.0.0/16 → local only    │     │
          │   └──────────────────────────────┘     │
          │                                        │
          └───────────────────────────────────────┘
                              |
                       [SSM Service]
                  Secure shell access
                  No inbound port 22
                  No key pair required
```

---

## What Was Built

| Component | Name | Value |
|---|---|---|
| VPC | tami-cloud | 10.0.0.0/16 |
| Public Subnet | public-tami-subnet | 10.0.1.0/24, us-east-2a |
| Private Subnet | private-tami-subnet | 10.0.2.0/24 |
| Internet Gateway | tami-cloud-gw | Attached to tami-cloud VPC |
| Public Route Table | tami-public-rt | 0.0.0.0/0 → IGW, local route |
| Private Route Table | tami-private-rt | Local route only, no IGW |
| Security Group | tami-security | No inbound rules, all outbound |
| IAM Role | ec2-ssm-role | AmazonSSMManagedInstanceCore policy |
| EC2 Instance | tami-ec2-server | Amazon Linux 2023, t2.micro |
| Access Method | SSM Session Manager | Online, Connected |
| Budget Alert | demo-budget | $5.00 monthly, alerts at 50% and 85% |

---

## Key Concepts Demonstrated

**Network Segmentation**
Public and private subnets serve different purposes. The public subnet hosts resources that need internet access. The private subnet isolates resources that should never be directly reachable from the internet. Route tables enforce this separation.

**Least Privilege IAM**
The EC2 instance uses an IAM instance profile rather than hardcoded credentials or access keys. The role has only the `AmazonSSMManagedInstanceCore` policy attached, granting the minimum permissions required for SSM access and nothing else.

**Zero Open Inbound Ports**
The security group has no inbound rules. SSM Session Manager authenticates through IAM and communicates outbound over HTTPS (port 443), meaning the instance is reachable for administration without exposing SSH, RDP, or any other port to the internet.

**Cost Controls**
A billing budget was configured before deploying any compute resources. Alerts fire at 50% and 85% of the monthly threshold, a practice that mirrors real cloud operations cost governance.

**Subnet Auto-assign IP**
Auto-assign public IPv4 is enabled on the public subnet and intentionally disabled on the private subnet. This ensures only instances in the public subnet receive routable public IPs.

---

## Screenshots

| Step | Description | File |
|---|---|---|
| 01 | IAM role created with AmazonSSMManagedInstanceCore | [view](docs/screenshots/01-iam-role.png) |
| 02 | VPC created (tami-cloud, 10.0.0.0/16) | [view](docs/screenshots/02-vpc-created.png) |
| 03 | Public subnet created (10.0.1.0/24) | [view](docs/screenshots/03-public-subnet.png) |
| 04 | Private subnet created (10.0.2.0/24) | [view](docs/screenshots/04-private-subnet.png) |
| 05 | Auto-assign public IP enabled on public subnet | [view](docs/screenshots/05-public-ip-enabled.png) |
| 06 | Internet gateway created and attached to VPC | [view](docs/screenshots/06-igw-attached.png) |
| 07 | Public route table with 0.0.0.0/0 to IGW route | [view](docs/screenshots/07-public-route-table.png) |
| 08 | Private route table with local route only | [view](docs/screenshots/08-private-route-table.png) |
| 09 | Security group with no inbound rules | [view](docs/screenshots/09-security-group.png) |
| 10 | EC2 instance launched in public subnet | [view](docs/screenshots/10-ec2-launched.png) |
| 11 | SSM Session Manager showing Online and Connected | [view](docs/screenshots/11-ssm-connected.png) |

---

## Files in This Repository

```
AWS-VPC-LAB/
├── README.md                        # This file
├── docs/
│   ├── architecture.md              # Deep dive on design decisions
│   ├── setup-guide.md               # Full step-by-step recreation guide
│   └── screenshots/                 # Console screenshots for each step
├── scripts/
│   └── verify-setup.sh              # Bash script to verify instance and connectivity
└── terraform/
    └── README.md                    # Placeholder for Terraform IaC version (in progress)
```

---

## How to Recreate This Lab

See [docs/setup-guide.md](docs/setup-guide.md) for the full step-by-step walkthrough.

**Prerequisites:**
- AWS account (free tier eligible)
- IAM user with administrative access (do not use root)
- Billing alert configured before deploying resources

**Estimated Cost:** Free tier eligible for the EC2 instance (t2.micro, Amazon Linux 2023). Stop or terminate the instance when not in use to avoid charges. The VPC, subnets, route tables, internet gateway, IAM role, and security group have no hourly cost.

---

## Skills Demonstrated

`AWS VPC` `Subnets` `Route Tables` `Internet Gateway` `Security Groups` `IAM Roles` `EC2` `SSM Session Manager` `Amazon Linux 2023` `Network Segmentation` `Least Privilege Access` `Cost Controls` `Cloud Networking`

---

## Next Steps

- [ ] Convert full infrastructure to Terraform (IaC)
- [ ] Add CloudWatch agent and log streaming to CloudWatch Log Groups
- [ ] Configure CloudWatch alarms and SNS email alerts
- [ ] Add a second EC2 instance in the private subnet
- [ ] Practice AWS CLI commands for all resources built here
- [ ] Add VPC Flow Logs to S3 for network traffic analysis

---

## References

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Free Tier](https://aws.amazon.com/free/)
