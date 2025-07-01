# Chatbot UI - DevOps CI/CD Project

This project demonstrates a complete CI/CD pipeline using Terraform and GitHub Actions to deploy a React-based chatbot UI to AWS ECS. It leverages modern DevOps best practices such as GitHub OIDC authentication, environment-specific config, and secure secret injection.

---

## ⚙️ Stack

* **React + TypeScript** – Chatbot UI frontend
* **Docker** – Containerized application build
* **Terraform** – Infrastructure as Code (modular structure)
* **AWS** – VPC, Internet Gateway, ECS & ECR (with Task Definition & Role), ALB, Route53, ACM, IAM, Security Groups
* **GitHub Actions** – CI/CD pipelines (infra & app)
* **GitHub OIDC** – Secure deployment via IAM roles

---

## ✅ Requirements

* AWS account
* GitHub account
* Terraform CLI
* GitHub CLI (optional but useful)

---

## 📦 Cloning the Repositories

Terraform Infrastructure: (https://github.com/adamlevi87/chatbot-ui-tf)

```bash
git clone https://github.com/adamlevi87/chatbot-ui-tf.git && cd chatbot-ui-tf
```

Application: (https://github.com/adamlevi87/chatbot-ui-gpt4-playground)

```bash
git clone https://github.com/adamlevi87/chatbot-ui-gpt4-playground.git
```

---

## 🔧 Setup

1. **Run Requirements (Locally)** From the `.requirements/` folder in the Terraform repo:

   ```bash
   terraform init && terraform plan && terraform apply
   ```

   This creates:

   * GitHub OIDC provider for trust (and a Role for connecting to AWS)
   * Backend resources (S3 + DynamoDB)

2. **In the Terraform repository**, manually create the following GitHub secrets and variable (one-time setup):

   * A **secret** named `TOKEN_GITHUB`. The value should be a GitHub PAT - fine-grained with access to the Application repository and with specific permissions (read access to metadata, and read/write access to Actions, variables, and secrets).
   * A **secret** named `AWS_ROLE_TO_ASSUME`. The value should be the ARN of the **role** that was just created when running Terraform apply in the ./requirement folder.
   * A **secret** named `PROVIDER_GITHUB_ARN`. The value should be the ARN of the **provider** that was just created when running Terraform apply in the ./requirement folder.
   * A **variable** named `AWS_REGION`. The value should be the region where you are working (e.g. `us-east-1`).

3. **Trigger Terraform Workflow**
   In the `chatbot-ui-tf` GitHub repo:

   * Use the Actions tab
   * Select the "Terraform Pipeline"
   * Set environment to `dev` and action to `plan-and-apply`
   * ⚠️ IMPORTANT: While the Apply is running, you must go to the new Route53 and set the required NS records in your custom domain registrar. Without this step, DNS resolution will not function for your deployed chatbot domain. Without this step, DNS resolution will not function for your deployed chatbot domain. Also, NS propagation can take a while which will make the workflow **fail**, just retry when the **propagation** has completed (or when the certificate's status in AWS is **Issued**)

4. **Trigger Application Deployment**
   In the `chatbot-ui-gpt4-playground` repo:

   * Manually trigger the "Build and Deploy" workflow (once infra is ready)

---

## 🧱 Project Structure

### chatbot-ui-tf (Terraform)

```
modules/              # Reusable Terraform modules
main/                 # Root module
environments/dev/     # Environment-specific config
requirements/         # Bootstrap resources (OIDC, backend)
.github/workflows/    # Terraform GitHub Actions workflow
```

### chatbot-ui-gpt4-playground (App)

```
Dockerfile            # Dockerized React app
.github/workflows/    # Build & deploy workflow to AWS ECS
```

---

## 🌐 Access

Your deployed chatbot will be available at:

```
https://chatbot-ui-gpt4-playground.projects-devops.cfd
```

---

## 🔐 Notes

* Terraform state is stored in S3 with locking via DynamoDB
* Secure GitHub OIDC auth is used for both infra and app
* Secrets and environment for the Application repository variables are provisioned via Terraform
* Network traffic is secured using **Security Groups**
* All environment-specific variables should be modified only inside the `terraform.tfvars` file located in each environment folder
* The `./requirements` folder initializes required trust & backend resources and must be executed before using the main infrastructure setup. It is intentionally decoupled from the rest of the Terraform configuration.

---

## 🧠 Highlights

* End-to-end infrastructure-as-code
* Zero hardcoded secrets
* Manual steps are minimal and clearly defined
* Real-world AWS and GitHub Actions integration

---

## 🧪 Common Commands (If working on a local environment)

```bash
# Run bootstrap resources (OIDC, backend)
cd .requirements/ && terraform apply

# Configure AWS credentials locally (if needed)
export AWS_ACCESS_KEY_ID="your_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region <your-region>
aws sts get-caller-identity  # Verify AWS identity

# Terraform Main job (Similar to what the workflow runs)
# Run Terraform from main/ folder
# change the path of backend-config & var-file to match the ENV you are working on
cd main/
# Initialize
terraform init \
  -backend-config=../environments/dev/backend.config \

# Plan
terraform plan \
  -var-file=../environments/dev/terraform.tfvars \
  -var="github_token=$TOKEN_GITHUB" \
  -var="aws_region=$AWS_REGION" \
  -var="provider_github_arn=$PROVIDER_GITHUB_ARN"

# Apply
terraform apply -auto-approve \
  -var-file=../environments/dev/terraform.tfvars \
  -var="github_token=$TOKEN_GITHUB" \
  -var="aws_region=$AWS_REGION" \
  -var="provider_github_arn=$PROVIDER_GITHUB_ARN"

# Destroy
terraform destroy -auto-approve \
  -var-file=../environments/dev/terraform.tfvars \
  -var="github_token=$TOKEN_GITHUB" \
  -var="aws_region=$AWS_REGION" \
  -var="provider_github_arn=$PROVIDER_GITHUB_ARN"

# Terraform State Inspection
terraform state list
terraform state show module.root.module.ecs_task_role.aws_iam_role.ecs_task_role
```
---
## 🗑️ Cleaning Up Leftover Resources

- All ECS **task definition revisions** should be manually de-registered.
- For resources created using the code in `./requirements`, either run:
  1. `terraform destroy`
  2. Or manually delete:
     - S3 bucket (note: currently protected from destruction)
     - DynamoDB table
     - IAM Role & OIDC Provider
- You may also delete the **manually created** GitHub secrets and variables in the Terraform repository.
---

This project was built for DevOps practice and interview readiness. Feel free to fork and adapt it to your own use case!

A rough illustration (just the basics):
![image](https://github.com/user-attachments/assets/a2dfaa0e-43af-4d58-8e67-d04225ae9baf)
