# Setup Guide: Recreate This Lab from Scratch

**Time to complete:** 30 to 45 minutes  
**Cost:** Free tier eligible (t2.micro, Amazon Linux 2023)  
**Region used:** us-east-2 (US East Ohio)  
**Prerequisite:** AWS account with an IAM admin user (not root)

---

## Step 1: Create the IAM Role

Do this before creating any EC2 instance. The role must exist before you can attach it at launch.

1. Go to IAM in the AWS Console
2. Click Roles in the left sidebar
3. Click Create role
4. Select AWS service as trusted entity type
5. Select EC2 as the use case
6. Click Next
7. Search for `AmazonSSMManagedInstanceCore` and check the box
8. Click Next
9. Role name: `ec2-ssm-role`
10. Click Create role
11. Verify the policy appears in the Permissions tab before proceeding

---

## Step 2: Create the VPC

1. Search for VPC in the console
2. Click Your VPCs
3. Click Create VPC
4. Select "VPC only" (not VPC and more)
5. Name tag: `tami-cloud`
6. IPv4 CIDR: `10.0.0.0/16`
7. Tenancy: Default
8. Click Create VPC
9. Confirm state shows Available

---

## Step 3: Create the Public Subnet

1. Click Subnets in the left sidebar
2. Click Create subnet
3. VPC ID: select `tami-cloud`
4. Subnet name: `public-tami-subnet`
5. Availability Zone: `us-east-2a`
6. IPv4 CIDR block: `10.0.1.0/24`
7. Click Create subnet

---

## Step 4: Create the Private Subnet

1. Click Create subnet
2. VPC ID: select `tami-cloud`
3. Subnet name: `private-tami-subnet`
4. Availability Zone: `us-east-2a`
5. IPv4 CIDR block: `10.0.2.0/24`
6. Click Create subnet

---

## Step 5: Enable Auto-Assign Public IP on Public Subnet Only

1. Select `public-tami-subnet` from the subnet list
2. Click Actions
3. Click Edit subnet settings
4. Check "Enable auto-assign public IPv4 address"
5. Click Save

Do NOT enable this on `private-tami-subnet`.

---

## Step 6: Create and Attach the Internet Gateway

1. Click Internet gateways in the left sidebar
2. Click Create internet gateway
3. Name tag: `tami-cloud-gw`
4. Click Create internet gateway
5. After creation, click Actions
6. Click Attach to VPC
7. Select `tami-cloud`
8. Click Attach internet gateway
9. Confirm state shows Attached

---

## Step 7: Create the Public Route Table

1. Click Route tables in the left sidebar
2. Click Create route table
3. Name: `tami-public-rt`
4. VPC: `tami-cloud`
5. Click Create route table
6. Click the Routes tab
7. Click Edit routes
8. Click Add route
9. Destination: `0.0.0.0/0`
10. Target: Internet Gateway, select `tami-cloud-gw`
11. Click Save changes
12. Confirm two routes are active: 0.0.0.0/0 → IGW and 10.0.0.0/16 → local

---

## Step 8: Associate the Public Route Table with the Public Subnet

1. In `tami-public-rt`, click the Subnet associations tab
2. Click Edit subnet associations
3. Check `public-tami-subnet`
4. Click Save associations

---

## Step 9: Create the Private Route Table

1. Click Create route table
2. Name: `tami-private-rt`
3. VPC: `tami-cloud`
4. Click Create route table
5. Do NOT add any route to the internet gateway
6. Click Subnet associations, Edit subnet associations
7. Check `private-tami-subnet`
8. Click Save associations

The private route table should have only the local route (10.0.0.0/16 → local).

---

## Step 10: Create the Security Group

1. Click Security groups in the left sidebar
2. Click Create security group
3. Name: `tami-security`
4. Description: Security group for tami cloud instances
5. VPC: `tami-cloud`
6. Inbound rules: add nothing
7. Outbound rules: confirm default all traffic 0.0.0.0/0 is present
8. Click Create security group

---

## Step 11: Launch the EC2 Instance

1. Go to EC2 in the console
2. Click Instances, then Launch instances
3. Name: `tami-ec2-server`
4. AMI: Amazon Linux 2023 (free tier eligible)
5. Instance type: `t2.micro`
6. Key pair: Proceed without a key pair
7. Network settings (click Edit):
   - VPC: `tami-cloud`
   - Subnet: `public-tami-subnet`
   - Auto-assign public IP: Enable
   - Security group: Select existing, choose `tami-security`
8. Advanced details:
   - IAM instance profile: `ec2-ssm-role`
9. Click Launch instance

---

## Step 12: Connect via SSM Session Manager

1. Wait for instance status to show Running and 2/2 checks passed
2. Wait an additional 2 to 3 minutes for the SSM agent to register
3. Select the instance
4. Click Connect
5. Click SSM Session Manager tab
6. Confirm Ping status shows Online and Session Manager connection status shows Connected
7. Click Connect

You now have a terminal session with no open inbound ports and no SSH key pair.

---

## Step 13: Verify the Setup in Terminal

Run these commands inside the SSM session:

```bash
# Confirm you are on the instance
whoami
hostname -I

# Confirm internet access through the IGW
curl -I https://aws.amazon.com

# Confirm SSM agent is running
sudo systemctl status amazon-ssm-agent

# View instance metadata (confirms IAM role is attached)
curl http://169.254.169.254/latest/meta-data/iam/info
```

Expected results:
- `whoami` returns `ssm-user`
- `hostname -I` returns a 10.0.1.x address (public subnet range)
- `curl` returns HTTP 200 or 301 (confirms IGW and route table work)
- SSM agent shows active (running)
- Metadata endpoint returns the IAM role ARN

---

## Teardown (Important: Avoid Charges)

When you are done with the lab, stop or terminate the EC2 instance to avoid ongoing charges. The instance is the only resource in this lab that costs money while running.

To fully clean up:

1. Terminate `tami-ec2-server`
2. Delete `tami-public-rt` and `tami-private-rt`
3. Detach and delete `tami-cloud-gw`
4. Delete `public-tami-subnet` and `private-tami-subnet`
5. Delete `tami-cloud` VPC
6. Delete the `tami-security` security group
7. Optionally delete `ec2-ssm-role` if not reusing

The IAM role can be kept and reused for future labs at no cost.
