# AWS IAM Setup for RHEL Graviton Deployments

This guide explains how to create an IAM user with permissions to:
- Deploy RHEL on Graviton VMs across multiple availability zones
- Create and manage Application Load Balancers (ALBs) that only accept HTTPS traffic (port 443)
- Manage SSL certificates with AWS Certificate Manager (ACM)

## Prerequisites

To create this IAM user, you must have administrative access to your AWS account. You can use either:

1. Your AWS root account (the email address you used to create the AWS account)
2. An existing IAM user that has administrative permissions (with the AdministratorAccess policy or equivalent)

**Security Best Practice:** Use an administrative IAM user instead of your root account whenever possible. The root account should only be used for tasks that specifically require root access.

## Creating the IAM User and Policy

### Step 1: Create a Policy Document

Create a file named `rhel-graviton-policy.json` with the following content:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:DescribeInstances",
                "ec2:TerminateInstances",
                "ec2:CreateTags",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:DescribeSecurityGroups",
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:ModifyVpcAttribute",
                "ec2:DescribeVpcAttribute",
                "ec2:CreateVpc",
                "ec2:DeleteVpc",
                "ec2:CreateSubnet",
                "ec2:DeleteSubnet",
                "ec2:CreateInternetGateway",
                "ec2:AttachInternetGateway",
                "ec2:DetachInternetGateway",
                "ec2:DeleteInternetGateway",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:DeleteRouteTable",
                "ec2:AssociateRouteTable",
                "ec2:DisassociateRouteTable",
                "ec2:DescribeRouteTables"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:Region": [
                        "us-east-2"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "StringLike": {
                    "ec2:InstanceType": "t4g.*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:subnet/*",
                "arn:aws:ec2:*:*:network-interface/*",
                "arn:aws:ec2:*:*:instance/*",
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:security-group/*",
                "arn:aws:ec2:*:*:key-pair/*",
                "arn:aws:ec2:*::image/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreatePolicy",
                "iam:DeletePolicy",
                "iam:CreatePolicyVersion",
                "iam:DeletePolicyVersion",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListPolicyVersions",
                "iam:SetDefaultPolicyVersion",
                "iam:ListPolicies"
            ],
            "Resource": "arn:aws:iam::265982090451:policy/rhel-graviton-policy"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:AddTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener"
            ],
            "Resource": "*",
            "Condition": {
                "NumericEquals": {
                    "elasticloadbalancing:ListenerPort": 443
                }
            }
        },
        {
            "Effect": "Deny",
            "Action": [
                "elasticloadbalancing:CreateListener"
            ],
            "Resource": "*",
            "Condition": {
                "NumericNotEquals": {
                    "elasticloadbalancing:ListenerPort": 443
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "acm:RequestCertificate",
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "acm:DeleteCertificate",
                "acm:AddTagsToCertificate",
                "acm:GetCertificate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange",
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": "*"
        }
    ]
}
```

### Step 2: Create the IAM Policy

Use the AWS CLI to create a policy from the JSON file:

```bash
aws iam create-policy \
    --policy-name RHELGravitonDeploymentPolicy \
    --policy-document file://rhel-graviton-policy.json
```

Note the ARN of the policy in the output. You'll need it in the next step.

### Step 3: Create the IAM User

Create a new IAM user:

```bash
aws iam create-user --user-name rhel-graviton-deployer
```

### Step 4: Attach the Policy to the User

Attach the policy to the user (replace the ARN with the one from Step 2):

```bash
aws iam attach-user-policy \
    --user-name rhel-graviton-deployer \
    --policy-arn arn:aws:iam::ACCOUNT_ID:policy/RHELGravitonDeploymentPolicy
```

### Step 5: Create Access Keys for the User

Generate access keys for the new user:

```bash
aws iam create-access-key --user-name rhel-graviton-deployer
```

Save the `AccessKeyId` and `SecretAccessKey` from the output. You'll need these to configure the AWS CLI.

## Configuring the AWS CLI to Use the New User

### Step 1: Create a New AWS CLI Profile

Add the new profile to your AWS credentials file:

```bash
# Add to ~/.aws/credentials
[rhel-graviton]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
```

Add region information to your AWS config file:

```bash
# Add to ~/.aws/config
[profile rhel-graviton]
region = us-east-2
output = json
```

### Step 2: Test the Configuration

Test that the new profile works:

```bash
aws ec2 describe-instances --profile rhel-graviton
```

## Using the IAM User with Ansible

In your Ansible playbook, you can use the new profile by adding the `--profile` parameter to all AWS CLI commands:

```yaml
- name: Create VPC using AWS CLI
  ansible.builtin.command:
    cmd: >
      aws ec2 create-vpc
      --cidr-block {{ vpc_cidr }}
      --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=rhel9-vpc}]'
      --region {{ aws_region }}
      --profile rhel-graviton
  register: vpc_result
  changed_when: true
```

Or, you can set the `AWS_PROFILE` environment variable before running your playbook:

```bash
export AWS_PROFILE=rhel-graviton
ansible-playbook deploy_rhel9_graviton.yml
```

## Security Considerations

This IAM user has been configured with the principle of least privilege in mind:

1. EC2 instances are restricted to t4g.small type (Graviton)
2. Operations are limited to specific AWS regions/availability zones
3. ALB listeners can only be created on port 443 (HTTPS)
4. Only the necessary ACM and Route53 permissions are granted for SSL certificate management

For enhanced security, consider further restrictions such as:
- Limiting to specific VPC IDs once they are created
- Adding resource-level permissions to restrict actions to specific resources
- Implementing a permission boundary for the user
- Using AWS Organizations Service Control Policies to add another layer of control