# Unified Multi-Repo Deployment Quality Governance Engine

## Enterprise SaaS Infrastructure & GitOps Platform

**Version:** `1.0.0`  
**Classification:** Production-Ready Banking-Grade Infrastructure  
**Compliance Frameworks:** SAMA (Saudi Arabian Monetary Authority), NCA (National Cybersecurity Authority)  
**Target Environment:** AWS Multi-AZ, Multi-Tenant, Zero-Trust

---

## 👶 The Simple Version (How It Works)

Imagine this project as a giant, super-smart factory for your code. Here is exactly what happens when you write code and send it here:

1. **You Write Code:** You finish typing your awesome code on your computer and press "Send" (or push it to GitHub).
2. **The Factory Checks It (Jenkins):** Think of Jenkins as the factory inspector. It looks at your code and asks: "Is this safe? Are there any bugs? Did they accidentally leave passwords in here?"
3. **Building the Box (Docker):** If the code passes the test, the factory packs your code into a neat, secure box called a "Container."
4. **The Delivery Truck (ArgoCD):** ArgoCD is the smart delivery truck. It constantly looks at the factory and says, "Oh, there's a new box!" It picks it up and drives it to its final home.
5. **The Final Home (Kubernetes/AWS):** This is the giant, safe playground where your app lives. The delivery truck drops your box here, and instantly, your app is live on the internet for everyone to use!
6. **The Guards and Cameras (Security & Observability):** While your app is running, security guards (Istio, Network policies) make sure bad guys can't get in, and cameras (Prometheus, Grafana) let you watch to make sure everything is running smoothly.

That's it! You write code, the factory checks it, packs it, delivers it, and keeps it safe.

---

## 💡 The Core Idea: Why does this exist?

If you have 10 different apps, you usually have 10 different ways of deploying them. Some might be secure, some might not be. Some might have bugs, some might leave passwords exposed. 

This project solves that chaos by acting as the **"One Governance Engine to Rule Them All."** Instead of every app having its own deployment script, all apps route through this unified engine. It automatically forces every piece of code to pass strict security tests (like checking for vulnerabilities or leaked secrets) before it is allowed to go live. It guarantees that no matter who writes the code or what the app does, it is deployed securely, consistently, and flawlessly every single time.

---

## 🏢 The Technical Details (For the Experts)

### WHAT is this?

This repository is a **Unified Multi-Repo Deployment Quality Governance Engine** — a comprehensive, enterprise-grade infrastructure and GitOps delivery platform designed to deploy, secure, and operate a highly scalable, multi-tenant Full-Stack TypeScript SaaS ecosystem on AWS. It functions as the central nervous system for continuous integration, continuous delivery, infrastructure provisioning, security governance, and observability across regulated financial services environments.

### Platform Topology

The architecture maps a complete traffic flow from the edge to the database:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              EDGE LAYER                                      │
│  Route53 (Geo-DNS + Health Checks) → Cloudflare (DDoS + WAF)                │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INGRESS LAYER                                        │
│  AWS ALB (Application Load Balancer)                                          │
│  ├── TLS 1.3 Termination (ACM Certificates)                                   │
│  ├── WebSocket Support                                                        │
│  └── AWS Load Balancer Controller (IngressClass: alb)                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SERVICE MESH LAYER                                      │
│  Istio Ingress Gateway (istio-ingressgateway)                                │
│  ├── VirtualService: Path-based routing (/ → UI, /api → Backend)             │
│  ├── DestinationRule: mTLS STRICT (Pod-to-Pod encryption)                    │
│  └── TrafficPolicy: 10% Canary split for zero-downtime deployments           │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     APPLICATION LAYER                                        │
│  ┌─────────────────────┐    ┌─────────────────────┐                          │
│  │  Frontend Pods      │    │  Backend Pods       │                          │
│  │  (React + Vite)     │    │  (Node + Express)   │                          │
│  │  Non-root UID       │    │  Non-root UID       │                          │
│  │  Read-only root FS  │    │  Read-only root FS  │                          │
│  └─────────────────────┘    └─────────────────────┘                          │
│           │                           │                                       │
│           └───────────┬───────────────┘                                       │
│                       │                                                       │
│              NetworkPolicies (L4/L7 filtering)                                │
│              Namespace Isolation per Tenant                                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                                         │
│  PgBouncer (Connection Pooling)                                               │
│  ├── max_client_conn: 10000                                                   │
│  ├── pool_mode: transaction                                                   │
│  └── Default pool size: 25 per db/user combo                                  │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     DATABASE LAYER                                           │
│  Amazon Aurora PostgreSQL                                                     │
│  ├── 1 Writer Instance (db.r6g.xlarge)                                       │
│  ├── 1-15 Auto-scaling Reader Instances                                       │
│  ├── KMS Encryption at Rest                                                   │
│  ├── Isolated Subnets (No Internet Gateway)                                   │
│  └── Multi-AZ with automatic failover (< 30s RTO)                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Core Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Frontend | React 18 + Vite + TypeScript | SPA with client-side routing |
| Backend | Node.js + Express + TypeScript + Prisma ORM | RESTful API with type-safe DB access |
| Database | Amazon Aurora PostgreSQL | HA relational datastore with auto-scaling reads |
| Connection Pooling | PgBouncer | Prevents connection exhaustion under high concurrency |
| Container Orchestration | Amazon EKS (Kubernetes 1.28+) | Managed K8s with IRSA and VPC CNI |
| Service Mesh | Istio 1.20+ | mTLS, traffic management, observability |
| Ingress | AWS ALB + Istio Gateway | Layer 7 routing with TLS termination |
| CI Orchestrator | Jenkins (Declarative Pipelines) | Build, test, and artifact creation |
| CD Engine | ArgoCD (App-of-Apps) | Pull-based GitOps continuous delivery |
| IaC | Terraform 1.6+ | Immutable, versioned infrastructure |
| Code Quality | SonarQube | Cognitive complexity, coverage, duplication gating |
| Secret Scanning | Gitleaks | Prevents credential leakage in commit history |
| Vulnerability Scanning | Trivy | OS and application dependency CVE detection |
| DAST | OWASP ZAP | Runtime security validation |
| Observability | Prometheus + Grafana + Loki | Metrics, dashboards, and centralized logging |

---

## HOW does this work?

This section provides a meticulous, step-by-step deployment runbook. Execute these operations in the exact sequence specified. Deviation from this order may result in failed dependency resolution or security misconfigurations.

### Prerequisites

Before initiating deployment, ensure the following are provisioned and accessible:

1. **AWS Account** with IAM administrative privileges
2. **AWS CLI** configured with profiles for each target environment (`prod`, `staging`)
3. **Terraform** `>= 1.6.0` installed locally
4. **kubectl** `>= 1.28.0` with `aws-iam-authenticator`
5. **Helm** `>= 3.13.0` for cluster add-on installation
6. **Docker** with buildx support for multi-architecture builds
7. **Jenkins** controller with Kubernetes plugin and configured AWS credentials
8. **ArgoCD** CLI (optional, UI is sufficient)
9. **Domain** registered in Route53 or delegated to Route53 from Cloudflare
10. **DynamoDB Table** for Terraform state locking (manual one-time bootstrap)
11. **S3 Bucket** for Terraform remote state (manual one-time bootstrap)

### Phase 0: Bootstrap Terraform Backend (One-Time)

Terraform requires a remote backend for state persistence and locking in team environments. Create these resources manually via the AWS Console or a local bootstrap Terraform configuration:

```bash
# Create the S3 bucket for state storage
aws s3 mb s3://unified-saas-terraform-state-prod --region me-central-1
aws s3api put-public-access-block \
  --bucket unified-saas-terraform-state-prod \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
aws s3api put-bucket-versioning \
  --bucket unified-saas-terraform-state-prod \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption \
  --bucket unified-saas-terraform-state-prod \
  --server-side-encryption-configuration \
  '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}}]}'

# Create the DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock-prod \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region me-central-1
```

### Phase 1: Initialize Infrastructure (Terraform)

Navigate to the production environment directory and initialize the Terraform workspace:

```bash
cd environments/prod
terraform init
terraform workspace select prod || terraform workspace new prod
terraform plan -out=tfplan
terraform apply tfplan
```

This operation will:

1. Provision the multi-AZ VPC with public, private, and isolated subnets.
2. Create the EKS cluster with managed node groups across AZs.
3. Deploy the Aurora PostgreSQL cluster inside isolated subnets.
4. Configure IAM Roles for Service Accounts (IRSA).
5. Deploy NAT Gateways per AZ for outbound connectivity from private subnets.
6. Output critical connection strings and ARNs for downstream consumption.

**Estimated Duration:** 25-35 minutes.

### Phase 2: Configure kubectl Access

After the EKS cluster is provisioned, update your local kubeconfig:

```bash
aws eks update-kubeconfig \
  --region me-central-1 \
  --name unified-saas-prod-cluster \
  --alias prod-eks

kubectl get nodes -o wide
```

### Phase 3: Install Cluster Add-ons

Install the required Kubernetes add-ons using Helm:

```bash
# Install Istio Service Mesh
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm install istio-base istio/base -n istio-system --create-namespace
helm install istiod istio/istiod -n istio-system --wait
helm install istio-ingressgateway istio/gateway -n istio-system --wait

# Label the default namespace for Istio sidecar injection
kubectl label namespace default istio-injection=enabled --overwrite

# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=unified-saas-prod-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# Install Prometheus + Grafana + Loki
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --values ../../observability/prometheus-values.yaml

helm install loki grafana/loki-stack \
  -n monitoring \
  --values ../../observability/loki-values.yaml
```

### Phase 4: Install and Configure ArgoCD

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd \
  -n argocd --create-namespace \
  --values ../../argocd/argocd-values.yaml

# Expose ArgoCD server via port-forward (or configure Ingress)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Retrieve initial admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

### Phase 5: Bootstrap ArgoCD App-of-Apps

Register the root application manifest so ArgoCD begins managing the cluster:

```bash
kubectl apply -f ../../argocd/application-root.yaml
```

This manifest instructs ArgoCD to recursively sync all application manifests located under the `apps/` and `networking/` directories.

### Phase 6: Configure Jenkins

1. Navigate to your Jenkins controller UI.
2. Install plugins: `Kubernetes`, `Docker Pipeline`, `Pipeline: Stage View`, `SonarQube Scanner`, `Credentials Binding`, `Amazon ECR`, `Git Parameter`.
3. Add the following credential entries:
   - `aws-ecr-credentials`: AWS IAM access key/secret with ECR push/pull permissions.
   - `sonarqube-token`: SonarQube analysis token.
   - `github-ssh-key`: SSH deploy key with write access to the GitOps manifest repository.
   - `gitops-repo-url`: The HTTPS or SSH URL of this repository.
4. Create a Multibranch Pipeline pointing to this repository.
5. Ensure the Jenkins agent has Docker, `yq`, `aws-cli`, `trivy`, and `gitleaks` installed.

### Phase 7: Database Schema Seed

Before the backend application can serve traffic, the Prisma schema must be deployed to Aurora PostgreSQL. This is handled automatically by the Jenkins pipeline via the `database/prisma-job.yaml` manifest, but for manual initialization:

```bash
# Port-forward to PgBouncer or connect via bastion host
kubectl apply -f ../../database/prisma-job.yaml
kubectl wait --for=condition=complete job/prisma-migrate-deploy -n default --timeout=300s
kubectl logs job/prisma-migrate-deploy -n default
```

### Phase 8: Register Jenkins Webhooks

In your Git repository settings (GitHub/GitLab), register a webhook pointing to:

```
https://<jenkins-controller>/github-webhook/
```

Configure the webhook to trigger on `push` and `pull_request` events.

### Phase 9: Validate End-to-End

```bash
# Verify all pods are healthy
kubectl get pods -A

# Verify Istio mTLS is enforced
istioctl authn tls-check <pod-name>.default

# Verify HPA is active
kubectl get hpa -n default

# Verify ArgoCD sync status
argocd app list

# Run smoke tests against the ALB endpoint
export APP_URL=$(kubectl get ingress -n istio-system -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
curl -sfk https://${APP_URL}/api/health || echo "Health check failed"
```

---

## WHY was this architecture chosen?

Every component in this platform was selected after careful evaluation of security posture, operational overhead, regulatory compliance, and real-world failure modes common in financial services SaaS platforms.

### Why Hybrid Push-Pull (Jenkins CI + ArgoCD CD)?

A pure Jenkins push model would require the CI system to hold long-lived cluster credentials (kubeconfig) with broad `cluster-admin` privileges. In a banking-grade environment, this violates the principle of least privilege and creates a high-value attack target. If Jenkins is compromised, the attacker gains direct write access to production.

ArgoCD implements a **pull-based GitOps** model:

- **No cluster credentials leave the boundary:** The CD agent runs inside the cluster and only pulls from Git. Jenkins never touches Kubernetes.
- **Auditable desired state:** The Git repository is the single source of truth. Every change is signed, peer-reviewed, and permanently logged.
- **Self-healing:** ArgoCD continuously reconciles drift. If a manual `kubectl patch` is applied, ArgoCD reverts it within minutes.
- **Granular RBAC:** ArgoCD supports project-level RBAC, allowing tenant teams to manage only their namespaces.

Jenkins remains the optimal CI engine because it excels at complex build orchestration (multi-arch Docker builds, parallel test matrices, artifact promotion). ArgoCD excels at declarative delivery. This hybrid model separates **build** from **deploy**, minimizing blast radius.

### Why Istio Service Mesh over Standard Kubernetes Services?

Standard Kubernetes Services provide Layer 4 load balancing but offer no encryption, no fine-grained traffic control, and no deep observability without additional tooling.

Istio was selected because:

- **mTLS (Mutual TLS):** All pod-to-pod communication is automatically encrypted and authenticated via SPIFFE identities. This satisfies NCA control requirements for encryption-in-transit and zero-trust networking without application-level changes.
- **Canary Deployments:** Istio's VirtualService and DestinationRule allow weighted traffic splitting (e.g., 10% canary). This enables zero-downtime deployments and automated rollback on SLO violation.
- **Network Policies on Steroids:** Istio AuthorizationPolicy provides Layer 7 filtering (HTTP paths, methods, JWT claims) beyond what standard NetworkPolicies can achieve.
- **Observability:** Istio generates distributed traces (Jaeger/Tempo), metrics (Prometheus), and access logs (Loki) without instrumentation.
- **Multi-Tenancy Isolation:** Istio supports tenant-bound namespaces with strict mTLS and egress controls, preventing lateral movement.

### Why PgBouncer Connection Pooling?

Node.js applications using Prisma create a persistent connection pool per instance. In a Kubernetes environment with 50 backend pods, each pod maintaining 20 connections to PostgreSQL, the database must support 1,000 concurrent connections. Aurora PostgreSQL has a hard limit (typically `max_connections = 500` on smaller instances). Without connection pooling, the database will reject new connections under load, causing cascading failures.

PgBouncer solves this via **transaction-level pooling**:

- **Dramatically lower connection count:** 50 pods × 20 Prisma connections → PgBouncer multiplexes them into ~25-50 actual PostgreSQL connections.
- **Faster failover:** When Aurora promotes a reader to writer, PgBouncer can reconnect transparently without restarting application pods.
- **Query queuing:** Under extreme load, PgBouncer queues requests instead of failing immediately, providing backpressure.
- **Isolated credential rotation:** PgBouncer credentials can be rotated independently of application credentials via Kubernetes Secrets.

### Why Amazon Aurora PostgreSQL?

Aurora provides 3x the throughput of standard PostgreSQL with automated storage scaling up to 128 TiB. For a multi-tenant SaaS:

- **High Availability:** Aurora automatically provisions a primary writer and up to 15 read replicas across AZs. Failover typically completes in under 30 seconds.
- **Auto-scaling:** Reader instances scale automatically based on CPU utilization, eliminating manual capacity planning for read-heavy workloads.
- **Storage Auto-scaling:** Storage grows automatically from 10 GiB to 128 TiB without downtime.
- **Backtrack:** Aurora supports "backtracking" to recover from destructive SQL queries without restoring from snapshots.
- **Compliance:** Aurora supports encryption at rest (KMS) and in transit (TLS), satisfying SAMA cybersecurity framework requirements.

### Why Non-Root Containers, Read-Only Filesystems, and NetworkPolicies?

In a zero-trust model, compromise is assumed. These controls limit the blast radius:

- **Non-root UID:** If a container escape vulnerability is exploited, the attacker gains host access as a non-privileged user, preventing kernel module loading or `/proc` manipulation.
- **Read-Only Root Filesystem:** Prevents malware persistence, log tampering, and binary modification inside the container.
- **NetworkPolicies:** By default, all cross-namespace traffic is denied. Only explicitly whitelisted CIDR blocks and pod selectors can communicate. This prevents a compromised frontend pod from scanning the database subnet or reaching the ArgoCD namespace.

### Why Terraform with Remote S3 State?

Terraform is the de facto standard for immutable infrastructure. Remote S3 state with DynamoDB locking ensures:

- **Team Safety:** Concurrent `terraform apply` operations are impossible due to state locking.
- **Audit Trail:** S3 versioning maintains a history of every infrastructure change.
- **Disaster Recovery:** State is not tied to a single engineer's laptop.
- **Compliance:** State files are encrypted at rest via KMS, satisfying data-at-rest encryption requirements.

---

## Repository Structure

```
.
├── README.md                          # This file — architectural blueprint and runbook
├── environments/
│   └── prod/
│       ├── main.tf                    # Root orchestration module for production
│       ├── variables.tf               # Environment-specific variable declarations
│       ├── outputs.tf                 # Exported values (cluster endpoint, DB endpoint)
│       ├── backend.tf                 # Remote S3 state + DynamoDB lock configuration
│       └── terraform.tfvars           # Sensitive variable values (gitignored in production)
├── modules/
│   ├── vpc/
│   │   ├── vpc.tf                     # Multi-AZ VPC with public/private/isolated subnets
│   │   ├── variables.tf               # Input parameters for the VPC module
│   │   └── outputs.tf                 # Subnet IDs, VPC ID, NAT Gateway IDs
│   ├── eks/
│   │   ├── eks.tf                     # EKS cluster, managed node groups, IRSA, KMS
│   │   ├── variables.tf               # Input parameters for the EKS module
│   │   └── outputs.tf                 # Cluster endpoint, CA certificate, OIDC issuer
│   └── rds/
│       ├── aurora.tf                  # Aurora PostgreSQL cluster + parameter groups
│       ├── variables.tf               # Input parameters for the RDS module
│       └── outputs.tf                 # Cluster endpoint, reader endpoint, port
├── docker/
│   ├── frontend.Dockerfile            # Multi-stage React + Vite build
│   └── backend.Dockerfile             # Multi-stage Node.js + Express + Prisma build
├── jenkins/
│   └── Jenkinsfile                    # Enterprise declarative pipeline
├── apps/
│   ├── frontend/
│   │   ├── deployment.yaml            # Frontend K8s deployment with security context
│   │   ├── service.yaml               # ClusterIP service
│   │   ├── hpa.yaml                   # Horizontal Pod Autoscaler
│   │   └── networkpolicy.yaml         # Zero-trust ingress/egress rules
│   └── backend/
│       ├── deployment.yaml            # Backend K8s deployment with probes
│       ├── service.yaml               # ClusterIP service
│       ├── hpa.yaml                   # Horizontal Pod Autoscaler
│       ├── networkpolicy.yaml         # Zero-trust ingress/egress rules
│       └── serviceaccount.yaml        # IRSA-bound service account
├── networking/
│   ├── ingress-istio.yaml             # Istio Gateway + VirtualService + DestinationRule
│   └── ingress-alb.yaml               # AWS ALB Ingress (optional fallback)
├── database/
│   └── prisma-job.yaml                # K8s Job for Prisma migrate deploy
├── argocd/
│   ├── application-root.yaml          # App-of-Apps manifest
│   └── argocd-values.yaml             # Helm values for ArgoCD installation
└── observability/
    ├── prometheus-values.yaml         # Prometheus + Grafana stack configuration
    └── loki-values.yaml               # Loki + Promtail log aggregation configuration
```

---

## Security & Compliance Matrix

| Control Domain | Implementation | SAMA / NCA Mapping |
|----------------|---------------|-------------------|
| Encryption at Rest | Aurora KMS + EBS encrypted volumes | SAMA CS-4.2, NCA ECC-1:2018 5.1.2 |
| Encryption in Transit | Istio mTLS + ALB TLS 1.3 + Aurora SSL | SAMA CS-4.3, NCA ECC-1:2018 5.1.3 |
| Identity & Access Management | IRSA + Least Privilege IAM + RBAC | SAMA CS-5.1, NCA ECC-1:2018 5.2 |
| Network Segmentation | VPC subnets + Security Groups + NetworkPolicies + Istio AuthZ | SAMA CS-6.1, NCA ECC-1:2018 5.3 |
| Vulnerability Management | Trivy (container scan) + SonarQube (SAST) + OWASP ZAP (DAST) | SAMA CS-7.2, NCA ECC-1:2018 5.4 |
| Secret Management | AWS Secrets Manager + Kubernetes Sealed Secrets | SAMA CS-8.1, NCA ECC-1:2018 5.5 |
| Logging & Monitoring | Prometheus + Grafana + Loki + CloudTrail | SAMA CS-9.1, NCA ECC-1:2018 5.6 |
| Patch Management | Automated base image rebuilds via Jenkins + Renovate | SAMA CS-10.1, NCA ECC-1:2018 5.7 |
| Change Management | GitOps with signed commits + ArgoCD audit trail | SAMA CS-11.1, NCA ECC-1:2018 5.8 |
| Data Segregation | Namespace isolation + Prisma Tenant ID column separation | SAMA CS-12.1, NCA ECC-1:2018 5.9 |

---

## Multi-Tenancy Architecture

Tenant isolation is implemented at three layers:

### 1. Network Layer (Kubernetes Namespaces)

Each tenant receives a dedicated namespace:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-acme-corp
  labels:
    istio-injection: enabled
    tenant-id: acme-corp
```

NetworkPolicies within each namespace deny all ingress/egress except:
- Ingress from `istio-ingressgateway` (tenant traffic entry)
- Egress to `pgbouncer` service (database access)
- Egress to `kube-dns` (DNS resolution)

Cross-namespace traffic is blocked by default via a global deny-all policy.

### 2. Application Layer (Prisma Middleware)

A custom Prisma middleware intercepts every query and injects the tenant context:

```typescript
// apps/backend/src/middleware/tenantIsolation.ts
export const tenantMiddleware = (tenantId: string) => {
  return async (params: any, next: any) => {
    if (params.model && params.args) {
      params.args.where = {
        ...params.args.where,
        tenantId: tenantId,
      };
    }
    return next(params);
  };
};
```

The Express application extracts the tenant ID from the JWT `sub` claim or a custom header (`X-Tenant-ID`) and applies the middleware to the Prisma client instance for that request.

### 3. Database Layer (Schema Separation)

The Prisma schema includes a mandatory `tenantId` column on every tenant-scoped table:

```prisma
model User {
  id        String   @id @default(uuid())
  tenantId  String   @map("tenant_id")
  email     String
  createdAt DateTime @default(now()) @map("created_at")

  @@index([tenantId])
  @@map("users")
}
```

Row-Level Security (RLS) policies are enforced at the PostgreSQL level as a defense-in-depth measure:

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_policy ON users
  USING (tenant_id = current_setting('app.current_tenant')::TEXT);
```

Before executing queries, the application sets the tenant context:

```sql
SET app.current_tenant = 'acme-corp';
```

---

## Operational Runbooks

### Manual Rollback Procedure

If a deployment introduces critical regressions:

```bash
# Identify the last known good image tag
git log --oneline -- apps/backend/deployment.yaml

# Revert the manifest in Git
git revert <commit-hash>
git push origin main

# ArgoCD will auto-sync to the previous state within 3 minutes
# Verify rollback:
kubectl rollout status deployment/backend-api -n default
```

### Database Credential Rotation

```bash
# 1. Update the secret in AWS Secrets Manager
aws secretsmanager put-secret-value \
  --secret-id prod/aurora/postgres-credentials \
  --secret-string '{"username":"api_user","password":"<NEW_PASSWORD>"}'

# 2. Trigger a rolling restart of backend pods to pick up the new secret
kubectl rollout restart deployment/backend-api -n default

# 3. Verify connectivity
kubectl logs -l app=backend-api -n default --tail=50
```

### Scaling Event Response

If HPA has scaled to max replicas and CPU remains elevated:

```bash
# Check if scaling is legitimate or due to a query N+1 issue
kubectl top pods -n default
kubectl logs -l app=backend-api -n default | grep -i "slow query"

# If legitimate traffic spike, manually scale node group
aws eks update-nodegroup-config \
  --cluster-name unified-saas-prod-cluster \
  --nodegroup-name backend-workloads \
  --scaling-config minSize=5,maxSize=20,desiredSize=10

# If query issue, apply a temporary rate limit at the Istio layer
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: EnvoyFilter
metadata:
  name: emergency-rate-limit
  namespace: default
spec:
  workloadSelector:
    labels:
      app: backend-api
  configPatches:
    - applyTo: HTTP_FILTER
      match:
        context: SIDECAR_INBOUND
      patch:
        operation: INSERT_BEFORE
        value:
          name: envoy.filters.http.local_ratelimit
          typed_config:
            "@type": type.googleapis.com/udpa.type.v1.TypedStruct
            type_url: type.googleapis.com/envoy.extensions.filters.http.local_ratelimit.v3.LocalRateLimit
            value:
              stat_prefix: http_local_rate_limiter
              token_bucket:
                max_tokens: 100
                tokens_per_fill: 100
                fill_interval: 1s
              filter_enabled:
                runtime_key: local_rate_limit_enabled
                default_value:
                  numerator: 100
                  denominator: HUNDRED
              filter_enforced:
                runtime_key: local_rate_limit_enforced
                default_value:
                  numerator: 100
                  denominator: HUNDRED
EOF
```

---

## Contributing & Governance

1. **Branch Protection:** The `main` branch requires 2 approving reviews, signed commits, and passing CI checks.
2. **Semantic Versioning:** All container images and Git tags follow SemVer (`v{major}.{minor}.{patch}-{git-sha}`).
3. **Change Advisory Board (CAB):** Infrastructure changes affecting the VPC, EKS control plane, or RDS cluster require CAB approval.
4. **Security Review:** Any modification to NetworkPolicies, Istio AuthorizationPolicies, or IAM roles must be reviewed by the Security Architecture team.

---

## License

This repository is proprietary and confidential. Unauthorized distribution or use is strictly prohibited.

**Engineered for resilience. Deployed with confidence. Governed with precision.**
