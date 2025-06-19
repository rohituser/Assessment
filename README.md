# DevOps Assessment Submission – Darwix AI

## 1. Infrastructure as Code (Terraform Configuration)
The provided Terraform script provisions a scalable, secure, and highly available AWS infrastructure to host a web application using NGINX on EC2. The configuration includes auto-scaling, load balancing, and robust networking.

### Key Components:
#### 1.1. VPC & Subnets
- **Custom VPC**: `10.0.0.0/16`
- **Subnets**: Two public and two private subnets across two Availability Zones

#### 1.2. Networking
- **Internet Gateway**: Provides public access
- **NAT Gateway**: Located in the public subnet for outbound access from private subnets
- **Route Tables**: Configured for public and private subnet routing

#### 1.3. Security Groups
- **ALB Security Group**: Allows HTTP/HTTPS from the internet
- **EC2 Security Group**: Allows HTTP only from the ALB
- **SSH Security Group**: Allows SSH access only from trusted IP addresses

#### 1.4. Compute
- **Launch Template**: Installs and starts NGINX with a sample static page
- **Auto Scaling Group**: Min: 1, Max: 3; deployed in private subnets using the launch template

#### 1.5. Load Balancer
- **ALB**: Deployed across public subnets
- **Target Group**: Forwards traffic to EC2 instances
- **Listener**: Routes HTTP traffic to the target group

#### 1.6. Deployment
- **ASG Attachment**: EC2 instances registered with the ALB
- **User Data**: Bootstraps NGINX and shows a welcome page

> ✅ `main.tf` script is included with the repository.

---

## 2. EC2 Bootstrapping and Configuration
Automates the initial setup of EC2 instances using a shell script.

### Script Highlights:
- **System Update**: Runs `yum update` to update all packages
- **NGINX Installation**:
  - Installed via Amazon Linux extras
  - Service enabled and started
  - Deploys `index.html` with welcome message
- **CloudWatch Logs Setup**:
  - Installs and configures the CloudWatch Logs agent
  - Sends logs for `/var/log/messages`, NGINX access, and error logs
  - Sets region to `us-east-1`
  - Starts the log agent

> ✅ `cloudwatch.sh` and `user-data.sh` scripts are included.

---

## 3. CI/CD Automation Design
Automated using a Jenkins pipeline for CI/CD.

### Jenkins Pipeline Overview:
1. **Checkout**: Pulls code from GitHub (master branch)
2. **Build**: Copies `index.html` to `build/` directory
3. **Package**: Zips the build folder into `app.zip`
4. **Upload**: Uploads to S3 bucket `s3-bucket-for-darvixassessment`
5. **Deploy**: Triggers deployment by updating ASG capacity (to refresh EC2s)

### Trigger Mechanism:
- Triggered via **GitHub webhook** on every code push

### Rollback Steps:
- **Artifact**: Restore previous version from S3
- **ASG**: Revert to previous launch template version

### Promotion Strategy:
- Deploy to staging ASG first
- Manual approval for promotion to production via Jenkins

> ✅ `Jenkinsfile` is included.

---

## 4. Security and Compliance Walkthrough
Implemented key security best practices:

### IAM Roles & Policies:
- EC2 Role with CloudWatch Logs and read-only S3 access
- Jenkins IAM User with `s3:PutObject` and `autoscaling:UpdateAutoScalingGroup`
- Bucket policy to **enforce SSL-only** access:
```json
{
  "Effect": "Deny",
  "Principal": "*",
  "Action": "s3:*",
  "Resource": "arn:aws:s3:::artifact-bucket/*",
  "Condition": {
    "Bool": {
      "aws:SecureTransport": "false"
    }
  }
}
```

### Secret Management:
- No hardcoded secrets in scripts
- Recommended use of AWS Secrets Manager or SSM Parameter Store with KMS

### Encryption:
- **At Rest**: SSE for S3, encrypted EBS volumes
- **In Transit**: HTTPS enforced for ALB and S3

### Governance:
- **CloudTrail**: Enabled to track API activities
- **GuardDuty**: Enabled for anomaly and threat detection

> ✅ `EC2role.json` policy file is included.

---

## 5. Optional Bonus Task – High-Level Solution

### Blue/Green Deployment:
- Two ASGs (Blue & Green)
- Single ALB with weighted target groups
- Traffic shifted to Green after validation
- Easy rollback by reverting traffic to Blue

### Zero-Downtime Updates:
- ASG Instance Refresh with health checks
- ALB with connection draining

### Cost Optimization:
- **Compute**: Spot Instances, Graviton, right-sizing
- **Storage**: S3 lifecycle rules, Intelligent Tiering
- **Network**: Single NAT Gateway, S3 VPC endpoints

---

## 📎 Attachments
- `main.tf` – Terraform infrastructure
- `cloudwatch.sh` – CloudWatch configuration script
- `user-data.sh` – EC2 bootstrapping script
- `Jenkinsfile` – CI/CD pipeline definition
- `EC2role.json` – IAM policy for EC2 instance role
