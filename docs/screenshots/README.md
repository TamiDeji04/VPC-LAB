# Screenshots

All screenshots are organized in order of the build process.

## Prefix Guide

| Prefix | Meaning |
|---|---|
| 00- | Pre-build setup (IAM user, billing alerts) |
| 01 to 12 | Main VPC build steps in order |
| ref- | Reference screenshots from earlier failed attempt |

## Pre-Build Screenshots (00-)

| File | What It Shows |
|---|---|
| 00-iam-create-admin-user.png | Creating tami-admin IAM user (not root) |
| 00-iam-create-admin-group.png | Creating admin group with AdministratorAccess |
| 00-iam-admin-group-created.png | Admin group successfully created |
| 00-iam-user-review.png | Review before creating IAM user |
| 00-iam-user-created.png | IAM user created successfully |
| 00-iam-group-permissions.png | Admin group permissions page |
| 00-iam-user-signin.png | Signed in as tami-admin (not root) |
| 00-billing-budget-type.png | Billing budget type selection |
| 00-billing-budget-amount.png | Budget set at $5.00 monthly |
| 00-billing-budget-scope.png | Budget scope configuration |
| 00-billing-alert-config.png | Alerts at 50% and 85% thresholds |

## Main Build Screenshots (01-12)

| File | What It Shows |
|---|---|
| 01-create-public-subnet.png | public-tami-subnet (10.0.1.0/24) creation |
| 02-create-private-subnet.png | private-tami-subnet (10.0.2.0/24) creation |
| 03-enable-public-ip-assignment.png | Auto-assign public IPv4 enabled on public subnet |
| 04-attach-igw-to-vpc.png | Attaching internet gateway to tami-cloud VPC |
| 05-igw-attached-confirmed.png | IGW state showing Attached |
| 06-add-igw-route-to-public-rt.png | Adding 0.0.0.0/0 to IGW route in public RT |
| 07-public-rt-routes-confirmed.png | Two routes active: IGW and local |
| 08-route-tables-overview.png | Both route tables visible in list |
| 09-public-rt-subnet-association.png | public-tami-subnet associated with public RT |
| 10-private-rt-subnet-association.png | private-tami-subnet associated with private RT |
| 11-security-group-creation.png | tami-security group setup |
| 11-security-group-final.png | Final security group with no inbound rules |
| 12-ssm-online-connected.png | SSM Session Manager: Online and Connected |

## Reference Screenshots (ref-)

These are from the earlier build attempt where SSM was offline.
Kept to show troubleshooting process and what was fixed.

| File | What It Shows |
|---|---|
| ref-vpc-overview.png | Original VPC attempt |
| ref-subnets-overview.png | Subnets from original attempt |
| ref-route-tables.png | Route tables from original attempt |
| ref-igw-overview.png | IGW from original attempt |
| ref-ssm-offline-before-fix.png | SSM showing Offline before fix (problem state) |
