## 🚀 AWS Auto Scaling Infrastructure with Private Subnets, NAT Gateway, and SSM Access

### 📘 Overview

This project provisions a highly available and secure AWS infrastructure using Terraform.
It demonstrates how to deploy a scalable web application in private subnets with auto scaling, load balancing, and secure access via AWS Systems Manager (SSM) — without exposing instances to the public Internet.

### 🧩 Architecture

```mermaid

%%{init: {
  "theme": "dark",
  "themeVariables": {
    "primaryColor": "#1f2937",
    "primaryTextColor": "#e5e7eb",
    "primaryBorderColor": "#4b5563",
    "lineColor": "#9ca3af",
    "secondaryColor": "#0f172a",
    "tertiaryColor": "#111827",
    "fontSize": "14px"
  }
}}%%
flowchart TB
  %% Groups
  subgraph Internet["🌐 Internet"]
    Client[(User / Browser)]
  end

  subgraph AWS["☁️ AWS Account / Region"]
    direction TB

    subgraph VPC["VPC (DNS On) 10.0.0.0/16"]
      direction TB

      %% Public tier
      subgraph Public["Public Subnets (ALB + NAT)"]
        direction TB
        IGW[[IGW]]
        ALB["⚖️ ALB (HTTP/HTTPS)"]
        NAT["🔁 NAT Gateway (EIP)"]
      end

      %% Private tier
      subgraph Private["Private Subnets (No Public IP)"]
        direction TB
        ASG["📈 Auto Scaling Group"]
        EC2A["🖥️ EC2 #1"]
        EC2B["🖥️ EC2 #2"]
      end
    end

    %% Control plane services (no direct path drawing to avoid clutter)
    subgraph Control["AWS Control / Management"]
      direction TB
      SSM["🔐 Systems Manager (SSM)"]
      CW["📊 CloudWatch (metrics/alarms)"]
    end
  end

  %% Traffic flow
  Client -->|HTTP/HTTPS| ALB
  ALB -->|Target Group : app_port| ASG
  ASG --> EC2A
  ASG --> EC2B

  %% Outbound path from private subnets
  EC2A -->|443 egress| NAT
  EC2B -->|443 egress| NAT
  NAT -->|0.0.0.0/0| IGW

  %% Mgmt
  EC2A -. SSM Agent (443) .-> SSM
  EC2B -. SSM Agent (443) .-> SSM
  EC2A -. Metrics/Logs .-> CW
  EC2B -. Metrics/Logs .-> CW

  %% Styling
  classDef tier fill:#0b1220,stroke:#334155,color:#e5e7eb;
  classDef node fill:#111827,stroke:#475569,color:#e5e7eb;
  classDef svc  fill:#0b3b2e,stroke:#22c55e,color:#eafff4;   %% mgmt services green-ish
  classDef net  fill:#0e1a2b,stroke:#60a5fa,color:#e5f0ff;   %% network blue-ish
  classDef edge stroke:#94a3b8,color:#cbd5e1;

  class VPC,Public,Private tier;
  class ALB,NAT,ASG,EC2A,EC2B,Client node;
  class SSM,CW svc;
  class IGW net;

```


### ⚙️ Key Components

| Component                           | Description                                               |
| ----------------------------------- | --------------------------------------------------------- |
| **VPC**                             | Custom VPC with DNS support enabled                       |
| **Public Subnets**                  | Contain the ALB and NAT Gateway                           |
| **Private Subnets**                 | Host EC2 instances managed by Auto Scaling                |
| **NAT Gateway**                     | Allows private instances to access the Internet securely  |
| **Auto Scaling Group (ASG)**        | Scales EC2 instances based on load                        |
| **Application Load Balancer (ALB)** | Distributes incoming traffic across EC2 instances         |
| **Security Groups**                 | Restrict inbound and outbound access per layer            |
| **IAM Roles**                       | Grant SSM and EC2 permissions securely                    |
| **SSM Agent Access**                | Enables shell access via AWS Console (no SSH keys needed) |


### 🧱 Terraform Structure

```bash

├── envs
│   └── dev
│       ├── backend.tf
│       ├── dev.tfvars
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfstate
│       ├── terraform.tfstate.backup
│       └── variables.tf
└── modules
    ├── alb
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── asg
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── ec2
    │   ├── datasource.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── user-data.sh
    │   └── variables.tf
    ├── monitoring
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── security_groups
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── vpc
        ├── datasource.tf
        ├── main.tf
        ├── outputs.tf
        └── variables.tf

```

### 🔐 Security Highlights

* **No public IP** on EC2 instances

* **SSM Session Manager** used for private access (no SSH)

* **Least privilege IAM roles** for EC2 and Terraform

* **Outbound-only Internet access** via NAT Gateway
  
* **Granular Security Groups** between ALB and EC2 tiers

### 🧰 Prerequisites

* Terraform ≥ 1.5
* AWS CLI configured (aws configure)
* An AWS IAM user or role with sufficient privileges to create VPC, EC2, IAM, and ALB resources
* A default region set in your AWS CLI config (e.g., us-east-1)

### 🚀 Deployment

``` bash
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### 🔍 Testing

After deployment:

**✅ Check SSM connectivity**

Go to AWS Console → Systems Manager → Fleet Manager → Managed Instances
Your EC2 instances should show "Online".

**✅ Test load balancing**
``` bash
curl http://<alb_dns_name>
```
**✅ Auto Scaling test**
``` bash
sudo yum install stress -y
stress --cpu 4 --timeout 300
```

