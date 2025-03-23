# 🚀 Deploy RHEL 9 on AWS Graviton with Ansible

## **Why RHEL 9 on AWS Graviton?**

Looking for a **faster, better, and cheaper** way to run your workloads on AWS? **Red Hat Enterprise Linux (RHEL) 9 on AWS Graviton** delivers **enterprise-grade performance and security** at a **fraction of the cost** of traditional x86 instances.

### **💰 Financial & Performance Benefits**
✅ **Superior Performance** – AWS Graviton’s custom **ARM-based CPUs** provide up to **40% better price-performance** than x86 alternatives.  
✅ **Lower Costs** – Graviton instances are **up to 20% cheaper** than Intel/AMD instances, reducing cloud spend significantly.  
✅ **Seamless RHEL Support** – Get all the benefits of **Red Hat’s stability, security, and enterprise support** on **cutting-edge hardware**.  
✅ **Energy Efficiency** – An additional bonus is that Graviton is **optimized for power consumption without sacrificing performance.**  

---

## **📜 What This Playbook Does**
This **Ansible playbook** automates the **deployment of a secure, scalable RHEL 9 environment** on AWS Graviton, complete with **containerized applications** and **load balancing**. Here’s what it does:

✔ **Deploys Three RHEL 9 Graviton Instances** across multiple AWS **availability zones** for **high availability**.  
✔ **Registers RHEL with Red Hat Subscription Manager (RHSM)** to enable system updates & support.  
✔ **Configures an AWS Load Balancer (ALB) with a Trusted SSL Certificate**, ensuring **secure HTTPS access**.  
✔ **Restricts SSH Access** to your **trusted IP** and **uploads a secure SSH key** for authentication.  
✔ **Installs & Configures Podman** to run **containerized applications**, authenticates with a **private registry**, and **deploys your containerized workload**.  
✔ **Redirects traffic to port 8080** on each instance, ensuring seamless, encrypted access via the ALB.  

---

## **🛠 How to Use This Playbook**
### **1️⃣ Prerequisites**
Before running this playbook, ensure you have:
- **Ansible** installed on your local machine
- **AWS CLI** configured with appropriate IAM permissions
- **A Red Hat Subscription** for registering RHEL instances
- **A public SSH key** to securely access instances

### **2️⃣ Update Your Variables**
Modify the `vars` section of `deploy_rhel9_graviton.yml` to include your own:
- **AWS Region & Credentials**
- **SSH Key & Trusted IP for Access**
- **Red Hat Subscription Manager (RHSM) Username, Password, and Pool ID**
- **Container Registry Credentials & Application Details**

### **3️⃣ Run the Playbook**
Execute the playbook with:
```bash
ansible-playbook deploy_rhel9_graviton.yml
```

### **4️⃣ Access Your Application**
Once complete, the playbook will output a **Load Balancer DNS URL**:
```bash
Access your application at https://rhel9-load-balancer-123456789.elb.amazonaws.com
```
Open this URL in your browser – **no SSL errors, fully encrypted!** 🔒

---

## **🐳 Why Use Podman for Containerized Applications?**

Podman is a **secure, lightweight, and daemonless** container engine designed for running, managing, and deploying containers. Unlike Docker, it does **not require a background daemon**, making it **more secure and resource-efficient**.

### **🔹 Key Benefits of Using Podman**
✅ **Rootless Security** – Run containers as a non-root user, **reducing attack surfaces** and security risks.  
✅ **Daemonless Architecture** – No always-running service, leading to **lower memory overhead** and fewer attack vectors.  
✅ **Seamless Docker Compatibility** – Use existing **Dockerfiles** and **OCI-compliant** images without modification.  
✅ **Kubernetes-Ready** – Easily generate Kubernetes YAML from running containers, enabling a **smooth transition to Kubernetes**.  
✅ **Enterprise-Grade Performance** – Optimized for **RHEL**, ensuring **stability, security, and reliability**.

By using **Podman on RHEL 9 Graviton**, you get a **lightweight, efficient, and secure** containerized application platform **without extra licensing costs** or unnecessary dependencies.  

---

## **🚀 Why You’ll Love This Deployment**
💰 **Lower AWS bills** – Get **Graviton’s price-performance advantage** without sacrificing security or performance.  
🔐 **Enterprise-grade security** – Red Hat’s trusted ecosystem meets AWS’s cloud-native security.  
⚡ **High-speed, low-latency performance** – Optimized for **modern containerized workloads**.  

💡 **In short:** More power, **less cost, no compromises**. Deploy RHEL 9 on Graviton, and **watch your cloud costs shrink** while your app **scales like never before**! 🚀🔥  

---

## **❓ Need Help?**
If you have any issues or need modifications, feel free to ask! 😊