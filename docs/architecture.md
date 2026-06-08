# Architecture Deep Dive

## Why Each Decision Was Made

---

### VPC CIDR: 10.0.0.0/16

A /16 block provides 65,536 IP addresses. This is deliberately oversized for a lab environment to mirror production VPC sizing, where teams reserve address space for future growth. Subnets carved from this block use /24 ranges (256 IPs each), leaving room to add more subnets without redesigning the address space.

---

### Public vs. Private Subnet Split

| Concern | Public Subnet | Private Subnet |
|---|---|---|
| Internet access | Yes, via IGW route | No, local only |
| Auto-assign public IP | Enabled | Disabled |
| Use case | Bastion hosts, public-facing resources | Databases, internal app servers |
| Route table | 0.0.0.0/0 → IGW | 10.0.0.0/16 → local |

In a real enterprise environment, web servers or load balancers sit in the public subnet while databases and application backends sit in the private subnet. This lab establishes that foundation.

---

### Internet Gateway

The IGW is a horizontally scaled, redundant AWS-managed component. It performs NAT for instances with public IPs and provides a target for the 0.0.0.0/0 route in the public route table. Attaching the IGW to the VPC alone does not give any instance internet access. The route table entry pointing 0.0.0.0/0 to the IGW is what actually enables traffic to flow. Both steps are required.

---

### Two Separate Route Tables

A common mistake is associating both subnets with the same route table. This lab uses two dedicated route tables to enforce isolation:

`tami-public-rt` has two routes:
- 10.0.0.0/16 → local (intra-VPC traffic stays inside)
- 0.0.0.0/0 → igw (all other traffic exits to internet)

`tami-private-rt` has one route:
- 10.0.0.0/16 → local (intra-VPC only, no internet exit)

Any instance in the private subnet cannot reach the internet and cannot be reached from the internet regardless of its security group configuration.

---

### Security Group Design

The `tami-security` group has zero inbound rules. This is intentional and is the correct configuration for SSM-managed instances.

Traditional SSH-based access requires opening port 22 inbound. This creates an attack surface: exposed ports can be brute-forced or exploited via SSH vulnerabilities. SSM Session Manager eliminates this entirely.

The outbound rule allowing all traffic to 0.0.0.0/0 enables the SSM agent to reach the SSM service endpoints over HTTPS (port 443). Without outbound HTTPS, SSM cannot register or maintain its connection.

---

### IAM Role: ec2-ssm-role

The role has one policy attached: `AmazonSSMManagedInstanceCore`. This AWS managed policy grants the exact permissions required for SSM to function:

- ssm:UpdateInstanceInformation (register instance)
- ssmmessages:* (Session Manager communication)
- ec2messages:* (EC2 message delivery for SSM)
- s3:GetEncryptionConfiguration (for encrypted session logging)

Nothing else. The instance cannot access S3 buckets, cannot call other AWS services, and cannot assume other roles. This is least privilege in practice.

The role is attached as an instance profile, meaning the EC2 instance receives temporary rotating credentials automatically. No access keys are stored on the instance.

---

### SSM Session Manager vs SSH

| Feature | SSH | SSM Session Manager |
|---|---|---|
| Inbound port required | Port 22 open | None |
| Key pair required | Yes | No |
| Audit logging | Manual setup | Native CloudWatch/S3 integration |
| Access control | Key file possession | IAM policy |
| Works from browser | No | Yes |
| Compliance friendly | Requires extra work | Built-in session logging |

For cloud engineering roles, SSM Session Manager is the enterprise-standard approach. Demonstrating it shows you understand modern access patterns rather than relying on legacy SSH key management.

---

### Cost Architecture

All resources in this lab fall into one of two categories:

**Zero cost:**
- VPC
- Subnets
- Route tables
- Internet gateway
- IAM role
- Security group

**Free tier eligible (with limits):**
- EC2 t2.micro: 750 hours/month free for 12 months on Amazon Linux
- Data transfer: 100GB outbound free per month

**Best practice applied:**
A billing budget with alerts at 50% and 85% was configured before any compute resources were deployed. This mirrors how responsible cloud teams operate: cost visibility comes before resource creation.

---

## What This Lab Proves to an Employer

A candidate who can build this correctly from scratch understands:

1. How VPC CIDR design affects subnet flexibility
2. Why route tables and internet gateways are two separate configuration steps
3. The difference between public and private network tiers
4. Why zero open inbound ports is better than port 22 access
5. How IAM instance profiles replace hardcoded credentials
6. What least privilege looks like in an EC2 context
7. How to implement cost controls before spending money

These are all concepts tested in AWS SysOps Administrator Associate and AWS Solutions Architect Associate exams, and all concepts cloud operations engineers use daily.
