# 🚀 Deploy RHEL 9 on AWS Graviton with Ansible

> **IMPORTANT:** This README has been sanitized to remove all sensitive information. Before using these playbooks, replace all placeholder values like `your-rhsm-username`, `your-rhsm-password`, `your-registry-username`, `your-registry-password`, and `your-ip-address` with your actual credentials and information.

## **Why Choose This Approach?**

This repository showcases both the power of RHEL 9 on AWS Graviton and the [advantages of Ansible for cross-cloud and hybrid deployments](#why-ansible-excels-for-cross-cloud-and-hybrid-cloud-deployments) through practical, production-ready automation.

## **Why RHEL 9 on AWS Graviton?**

Looking for a **faster, better, and cheaper** way to run your workloads on AWS? **Red Hat Enterprise Linux (RHEL) 9 on AWS Graviton** delivers **enterprise-grade performance and security** at a **fraction of the cost** of traditional x86 instances.

### **💰 Financial & Performance Benefits**
✅ **Superior Performance** – AWS Graviton's custom **ARM-based CPUs** provide up to **40% better price-performance** than x86 alternatives.  
✅ **Lower Costs** – Graviton instances are **up to 20% cheaper** than Intel/AMD instances, reducing cloud spend significantly.  
✅ **Seamless RHEL Support** – Get all the benefits of **Red Hat's stability, security, and enterprise support** on **cutting-edge hardware**.  
✅ **Energy Efficiency** – An additional bonus is that Graviton is **optimized for power consumption without sacrificing performance.**  

---

## **📜 What This Playbook Does**
This **Ansible playbook** automates the **deployment of a secure, scalable RHEL 9 environment** on AWS Graviton, complete with **containerized applications** and **load balancing**. Here's what it does:

✔ **Deploys Three RHEL 9 Graviton Instances** across multiple AWS **availability zones** for **high availability**.  
✔ **Registers RHEL with Red Hat Subscription Manager (RHSM)** to enable system updates & support.  
✔ **Configures an AWS Load Balancer (ALB) with a Trusted SSL Certificate**, ensuring **secure HTTPS access**.  
✔ **Restricts SSH Access** to your **trusted IP** and **uploads a secure SSH key** for authentication.  
✔ **Installs & Configures Podman** to run **containerized applications**, authenticates with a **private registry**, and **deploys your containerized workload**.  
✔ **Redirects traffic to port 8080** on each instance, ensuring seamless, encrypted access via the ALB.  

### **🧠 Enhanced State Management Features**
Our playbook now includes powerful state management capabilities to solve common AWS deployment challenges:

✅ **Resource Tagging & Tracking** - All AWS resources are tagged with consistent identifiers for easy management  
✅ **State File Generation** - Creates a comprehensive JSON state file of all deployed resources  
✅ **AWS Systems Manager Integration** - Stores resource IDs in SSM Parameter Store for cross-account access  
✅ **Deployment IDs** - Unique identifiers for each deployment to track and manage resources  
✅ **Resource Groups** - AWS resource groups to visualize all deployment components together  
✅ **Server-Side Automation** - Enhanced UserData scripts reduce network round-trips  
✅ **Idempotent Operations** - Improved handling of resource existence checks  
✅ **Easy Cleanup** - State file integration with cleanup playbook for reliable resource removal  

---

## **🛠 How to Use This Playbook**
### **1️⃣ Prerequisites**
Before running this playbook, ensure you have:
- **Ansible** installed on your local machine
- **AWS CLI** configured with appropriate IAM permissions
- **A Red Hat Subscription** for registering RHEL instances

### **2️⃣ Set Up AWS IAM Permissions**

This deployment requires specific AWS IAM permissions. For your convenience, two playbooks are included to manage these permissions:

#### Creating the Required IAM User

Run the provided IAM user creation playbook:

```bash
ansible-playbook create-iam-user.yml
```

This playbook will:
- Create an IAM policy based on `rhel-graviton-policy.json`
- Create a new IAM user (`rhel-graviton-deployer`)
- Attach the policy to the user
- Create access keys for the user
- Configure the AWS CLI with a new profile
- Save credentials to a backup file and display them

The output will show the new user's credentials and explain how to use the profile.

#### Using the IAM User

After running the creation playbook:

1. **Set the AWS Profile for Your Deployment**

```bash
export AWS_PROFILE=rhel-graviton-deployer
```

2. **Verify Access**

```bash
aws sts get-caller-identity
```

You should see output showing the `rhel-graviton-deployer` user and your AWS account ID.

### **3️⃣ Update Your Variables**
Modify the `vars` section of `deploy_rhel9_graviton.yml` to include your own:
- **AWS Region & Credentials**
- **SSH Key & Trusted IP for Access**
- **Red Hat Subscription Manager (RHSM) Username, Password, and Pool ID**
- **Container Registry Credentials & Application Details**

### **4️⃣ Run the Playbook**
Execute the playbook with:
```bash
# Standard execution
ansible-playbook deploy_rhel9_graviton.yml

# For EC2 deployments, disable host key checking to avoid SSH connection issues
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook deploy_rhel9_graviton.yml
```

The `ANSIBLE_HOST_KEY_CHECKING=False` option is especially important when deploying to newly created EC2 instances, as it prevents Ansible from getting stuck waiting for SSH host key confirmation. This happens because EC2 instances get new host keys every time they're created, which would normally trigger a security warning.

You can also make this permanent for AWS deployments by adding to your ansible.cfg:
```ini
[defaults]
host_key_checking = False
```

Or by setting in your environment:
```bash
export ANSIBLE_HOST_KEY_CHECKING=False
```

### **5️⃣ Access Your Application**
Once complete, the playbook will output a **Load Balancer DNS URL**:
```bash
Access your application at https://rhel9-load-balancer-123456789.elb.amazonaws.com
```
Open this URL in your browser – **no SSL errors, fully encrypted!** 🔒

### **6️⃣ Cleanup When Finished**

When you're done with your deployment, you can clean everything up with these provided playbooks:

#### Clean Up AWS Infrastructure

```bash
# Using state file (recommended - more reliable resource tracking)
ansible-playbook cleanup-playbook.yml -e @rhel9-graviton-state-YYYY-MM-DD-HH-MM-SS.json

# Or traditional method (less reliable but works if you've lost the state file)
ansible-playbook cleanup-playbook.yml
```

The improved cleanup playbook:
- Uses the state file to directly target resources for deletion
- Queries AWS Systems Manager Parameters for backup resource information
- Deletes resources in the proper dependency order
- Handles complex dependencies like network interfaces
- Provides detailed debugging information
- Verifies complete removal of all resources
- Cleans up state files and local SSH keys

#### Clean Up IAM User

When you're finished with the IAM user created for this deployment:

```bash
# Remove the IAM user and policy
ansible-playbook cleanup-iam-user.yml
```

This playbook will:
- Delete all access keys for the IAM user
- Detach policies from the user
- Delete the IAM user and policy
- Remove the AWS CLI profile configuration
- Delete the credentials backup file

---

## <img src="https://www.vectorlogo.zone/logos/podmanio/podmanio-ar21~bgwhite.svg" width="25" style="vertical-align: middle; margin-right: 5px;"> **Why Use Podman for Containerized Applications?**

Podman is a **secure, lightweight, and daemonless** container engine designed for running, managing, and deploying containers. Unlike Docker, it does **not require a background daemon**, making it **more secure and resource-efficient**.

### **🔹 Key Benefits of Using Podman**
✅ **Rootless Security** – Run containers as a non-root user, **reducing attack surfaces** and security risks.  
✅ **Daemonless Architecture** – No always-running service, leading to **lower memory overhead** and fewer attack vectors.  
✅ **Seamless Docker Compatibility** – Use existing **Dockerfiles** and **OCI-compliant** images without modification.  
✅ **Kubernetes-Ready** – Easily generate Kubernetes YAML from running containers, enabling a **smooth transition to Kubernetes**.  
✅ **Enterprise-Grade Performance** – Optimized for **RHEL**, ensuring **stability, security, and reliability**.

By using **Podman on RHEL 9 Graviton**, you get a **lightweight, efficient, and secure** containerized application platform **without extra licensing costs** or unnecessary dependencies.  

---

## **🚀 Why You'll Love This Deployment**
💰 **Lower AWS bills** – Get **Graviton's price-performance advantage** without sacrificing security or performance.  
🔐 **Enterprise-grade security** – Red Hat's trusted ecosystem meets AWS's cloud-native security.  
⚡ **High-speed, low-latency performance** – Optimized for **modern containerized workloads**.  

💡 **In short:** More power, **less cost, no compromises**. Deploy RHEL 9 on Graviton, and **watch your cloud costs shrink** while your app **scales like never before**! 🚀🔥  

---

## **⚙️ Security Considerations**

This IAM user has been configured with the principle of least privilege in mind:
- Operations are restricted to essential services needed for deployment
- Only necessary permissions are granted for EC2, ELB, ACM, and Route53
- The policy is designed to allow running Graviton instances and managing HTTPS load balancers

For enhanced security, consider:
- Further restricting to specific VPC IDs once created
- Adding resource-level permissions for more granular control
- Implementing permission boundaries
- Using AWS Organizations Service Control Policies for additional control layers

---

## **Advanced State Management for Hybrid Cloud**

For hybrid cloud environments, consider these additional options:

### 1. Ansible Automation Platform (AAP) Integration
Store your state in Ansible Automation Platform to:
- Maintain centralized state across deployments
- Enable role-based access to state data
- Schedule recurring resource cleanup
- Keep encryption keys secure

### 2. Cross-Cloud State Management
For multi-cloud deployments:
- Use consistent tagging patterns across clouds 
- Consider a centralized state database
- Implement cross-cloud resource groups

### 3. Red Hat Hybrid Cloud Console Integration
For Red Hat Enterprise environments:
- Integrate with Red Hat Hybrid Cloud Console
- Register instances automatically
- Create service catalog items
- Use consistent namespaces across OpenShift and cloud environments

---

## **Why Ansible Excels for Cross-Cloud and Hybrid Cloud Deployments**

Ansible provides unique advantages for organizations managing hybrid and multi-cloud environments:

**True Infrastructure-as-Code Without Lock-in**: Unlike CloudFormation (AWS-only) or Azure Resource Manager templates, Ansible works consistently across AWS, GCP, Azure, Oracle Cloud, and on-premises infrastructure, allowing you to standardize automation regardless of where workloads run.

**Single Control Point for Everything**: Ansible doesn't just configure cloud resources - it seamlessly extends to network devices (Cisco, Juniper, Arista), storage systems (NetApp, Pure), security appliances, and even IoT devices. This creates a unified automation framework spanning your entire technology estate.

**Workflow Orchestration Across Boundaries**: A single Ansible playbook can provision cloud resources, configure on-premises networking, update database schemas, and manage container platforms - eliminating integration gaps between specialized tools.

**Progressive Automation Adoption**: Teams can start with simple tasks and gradually expand automation coverage without wholesale replacements of existing systems - ideal for enterprises with mixed traditional and cloud-native environments.

**Human-Readable Syntax**: YAML-based playbooks are accessible to operations teams without specialized programming skills, lowering the barriers to automation adoption across your organization.

**Red Hat's Enterprise Support**: For production environments, Ansible Automation Platform provides the certified content, role-based access controls, and support SLAs that enterprises require for mission-critical automation.

In essence, Ansible lets you write once and deploy anywhere, treating everything from legacy mainframes to cutting-edge cloud services as part of a cohesive automation strategy.
