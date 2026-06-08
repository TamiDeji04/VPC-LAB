#!/bin/bash

# AWS VPC Lab Verification Script
# Run this inside an SSM Session Manager terminal session
# on the tami-ec2-server instance

echo "============================================"
echo "  AWS VPC Architecture Lab - Verification  "
echo "============================================"
echo ""

# Check 1: Current user
echo "[CHECK 1] Current user"
echo "Expected: ssm-user"
echo "Actual:   $(whoami)"
echo ""

# Check 2: Private IP address (should be in 10.0.1.0/24 range)
echo "[CHECK 2] Private IP address"
echo "Expected: 10.0.1.x (public subnet range)"
echo "Actual:   $(hostname -I | awk '{print $1}')"
echo ""

# Check 3: Internet connectivity via Internet Gateway
echo "[CHECK 3] Internet connectivity (via Internet Gateway)"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 https://aws.amazon.com)
if [ "$HTTP_STATUS" == "200" ] || [ "$HTTP_STATUS" == "301" ] || [ "$HTTP_STATUS" == "302" ]; then
    echo "PASS: Internet reachable (HTTP $HTTP_STATUS)"
else
    echo "FAIL: Internet not reachable (HTTP $HTTP_STATUS)"
fi
echo ""

# Check 4: SSM Agent status
echo "[CHECK 4] SSM Agent status"
SSM_STATUS=$(sudo systemctl is-active amazon-ssm-agent)
if [ "$SSM_STATUS" == "active" ]; then
    echo "PASS: SSM agent is $SSM_STATUS"
else
    echo "FAIL: SSM agent is $SSM_STATUS"
fi
echo ""

# Check 5: IAM role attached (via instance metadata)
echo "[CHECK 5] IAM role attached to instance"
IAM_INFO=$(curl -s --max-time 3 http://169.254.169.254/latest/meta-data/iam/info 2>/dev/null)
if echo "$IAM_INFO" | grep -q "InstanceProfileArn"; then
    ROLE=$(echo "$IAM_INFO" | grep -o '"InstanceProfileArn" : "[^"]*"' | cut -d'"' -f4)
    echo "PASS: IAM role attached"
    echo "      ARN: $ROLE"
else
    echo "FAIL: No IAM role detected on this instance"
fi
echo ""

# Check 6: Instance region
echo "[CHECK 6] AWS Region"
REGION=$(curl -s --max-time 3 http://169.254.169.254/latest/meta-data/placement/region)
echo "Region: $REGION"
echo ""

# Check 7: Instance type
echo "[CHECK 7] Instance type"
INSTANCE_TYPE=$(curl -s --max-time 3 http://169.254.169.254/latest/meta-data/instance-type)
echo "Instance type: $INSTANCE_TYPE"
echo ""

# Check 8: AMI ID
echo "[CHECK 8] AMI"
AMI=$(curl -s --max-time 3 http://169.254.169.254/latest/meta-data/ami-id)
echo "AMI ID: $AMI"
echo ""

echo "============================================"
echo "  Verification complete"
echo "============================================"
echo ""
echo "If all checks passed:"
echo "  VPC routing is working"
echo "  Internet Gateway is functional"
echo "  SSM access is confirmed"
echo "  IAM least-privilege role is attached"
echo ""
echo "Run 'sudo systemctl status amazon-ssm-agent' for full SSM agent details"
