# Clinic Platform

A production-ready, HIPAA-compliant clinic management platform — covering architecture, deployment pipeline, Kubernetes setup, blue/green deployments, and audit logging.

---

## Overview

This repository contains the full platform for managing clinic operations including patient scheduling, EHR/EMR records, billing, notifications, and integrations with lab systems and payment processors.

| Layer | Technology |
|---|---|
| Frontend | React (patient portal, staff dashboard, mobile, admin) |
| API Gateway | Kong / AWS API Gateway |
| Core Services | Node.js microservices (scheduling, EHR, billing, notifications) |
| Database | PostgreSQL via AWS RDS (encrypted, private subnet) |
| Cache | Redis (sessions, rate limiting) |
| File Storage | AWS S3 with object-level encryption |
| Message Queue | AWS SQS / RabbitMQ |
| Container Orchestration | Kubernetes (EKS) |
| CI/CD | GitHub Actions + ArgoCD |
| Secrets | HashiCorp Vault |
| Monitoring | Grafana, CloudWatch, PagerDuty |

---

## Architecture

```
Client Layer (Portal / Dashboard / Mobile / Admin)
        │
  API Gateway (auth, routing, rate limiting)
        │
  ┌─────┴──────────────────────────────┐
  │         Core Services              │
  │  Scheduling │ EHR │ Billing │ Notifications │
  └─────┬──────────────────────────────┘
        │
  ┌─────┴─────────────────┐
  │ Data       │ Integrations │
  │ RDS + S3   │ Labs + Payments │
  └───────────────────────┘
        │
  Infrastructure (K8s, HIPAA, Monitoring, CI/CD)
```

---

## Repository Structure

```
clinic-platform/
├── services/
│   ├── api-gateway/          # Kong config / gateway service
│   ├── scheduling/           # Appointment booking service
│   ├── ehr/                  # Electronic health records service
│   ├── billing/              # Invoicing and insurance claims
│   └── notifications/        # SMS / email / push worker
├── frontend/
│   ├── patient-portal/       # React patient-facing app
│   ├── staff-dashboard/      # React staff/doctor app
│   └── admin-panel/          # React admin interface
├── infra/
│   ├── k8s/                  # Kubernetes manifests
│   │   ├── namespaces/
│   │   ├── deployments/
│   │   ├── services/
│   │   ├── ingress/
│   │   ├── configmaps/
│   │   ├── network-policies/
│   │   └── hpa/
│   ├── terraform/            # Cloud infrastructure as code
│   └── vault/                # Vault policies and config
├── .github/
│   └── workflows/
│       ├── ci.yml            # CI pipeline (test, scan, build)
│       └── cd.yml            # CD pipeline (deploy via ArgoCD)
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── hipaa-compliance.md
│   └── runbooks/
└── README.md
```

---

## CI/CD Pipeline

Every pull request triggers the full CI pipeline:

1. **Checkout** — clone repo, set environment
2. **Install deps** — npm / pip / maven
3. **Lint + format** — ESLint, Prettier
4. **Unit tests** — Jest / PyTest / JUnit
5. **Integration tests** — API, DB, service calls
6. **SAST scan** — Snyk, SonarQube
7. **Dependency audit** — CVE and license checks
8. **Docker build** — multi-stage image
9. **Image scan** — Trivy / ECR scan
10. **HIPAA compliance gates** — policy checks
11. **Push to registry** — tagged and signed image
12. **CD trigger** → deploy to staging

Merges to `main` auto-deploy to staging via ArgoCD. Production requires a manual approval gate.

---

## Kubernetes Setup

Two namespaces provide a security boundary between application and data layers:

**`namespace: app`**
- API gateway (2+ replicas, HPA enabled)
- Core service pods (scheduling, EHR, billing, notifications)
- Frontend static serving
- ConfigMaps, Vault-injected secrets, network policies

**`namespace: data`**
- DB proxy → RDS (encrypted, private subnet only)
- Redis cache (sessions, rate limiting)
- Object storage CSI driver (S3/GCS)
- Message queue (SQS / RabbitMQ)

Network policies enforce explicit allow-lists — no pod-to-pod communication is permitted by default.

---

## Blue/Green Deployment

Production deployments use a blue/green strategy for zero-downtime releases:

1. New version deployed to the **green** environment (0% traffic)
2. Smoke tests and health checks run against green
3. Ingress selector updated — 100% traffic switches instantly
4. Blue kept warm for immediate rollback if needed
5. After 30-minute observation window, old blue is decommissioned

Rollback time: **< 30 seconds** (single ingress update).

---

## HIPAA Compliance

### Audit Logging

Every PHI access event is logged with:

```json
{
  "timestamp": "2025-03-22T14:32:01Z",
  "user_id": "usr_abc123",
  "user_role": "physician",
  "patient_id": "pat_xyz789",
  "action": "READ",
  "resource": "medication_list",
  "ip_address": "10.0.1.5",
  "result": "success"
}
```

Logs flow through Fluentd → Kinesis to:
- **SIEM** (Splunk/Datadog) — real-time alerting
- **S3 with Object Lock (WORM)** — 6-year immutable retention

### Security Controls

- All data encrypted at rest (AES-256) and in transit (TLS 1.3)
- Secrets managed via HashiCorp Vault (never in env vars or source code)
- Network policies restrict pod-to-pod communication
- Role-based access control (RBAC) with least-privilege
- Audit trail for all admin actions and PHI access

---

## Getting Started

### Prerequisites

- Docker + kubectl
- AWS CLI configured
- Vault CLI
- Node.js 20+

### Local Development

```bash
# Clone the repo
git clone https://github.com/your-username/clinic-platform.git
cd clinic-platform

# Start all services locally
docker compose up

# Run tests
npm run test --workspaces

# Deploy to local k8s (minikube)
kubectl apply -f infra/k8s/
```

### Deploying to Staging

Push to `main` — ArgoCD picks up the new image tag and deploys automatically.

### Deploying to Production

1. Create a release tag: `git tag v1.x.x && git push --tags`
2. Approve the production gate in GitHub Actions
3. Monitor the blue/green switch in the ArgoCD dashboard

---

## Documentation

- [Architecture overview](docs/architecture.md)
- [Deployment guide](docs/deployment.md)
- [HIPAA compliance notes](docs/hipaa-compliance.md)
- [Runbooks](docs/runbooks/)

---

## License

MIT
