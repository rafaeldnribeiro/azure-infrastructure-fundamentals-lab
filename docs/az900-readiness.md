# Microsoft Certified: Azure Fundamentals (AZ-900) Readiness Matrix

## Syllabus & Weighting Structure (2026 Syllabus)

The AZ-900 certification exam evaluates competencies across three core functional domains:
- **Domain 1**: Describe cloud concepts (25–30%)
- **Domain 2**: Describe Azure architecture and services (35–40%)
- **Domain 3**: Describe Azure management and governance (30–35%)

---

## Detailed Competency & Gap Analysis Matrix

Classification Key:
- `[Practical]`: Practical local tooling, scripts, or validated configuration tested and executed.
- `[Studied / IaC Validated]`: Conceptual models, architectural documentation, runbooks, and statically validated Bicep templates.
- `[Gap]`: Knowledge area identified for upcoming hands-on laboratory iteration.

| Topic / Objective | Functional Domain | Status | Evidence in Repository | Identified Gap | Next Action |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Shared Responsibility Model** | Cloud Concepts | [Studied / IaC Validated] | `compute/compute-decision-matrix.md`, `docs/architecture.md` | Practical audit of security boundaries | Review matrix in practice assessments |
| **Cloud Models (Public/Private/Hybrid)** | Cloud Concepts | [Studied / IaC Validated] | `docs/architecture.md` | Hybrid connectivity lab (VPN gateway) | Study hybrid architecture runbooks |
| **Cloud Service Types (IaaS/PaaS/SaaS)** | Cloud Concepts | [Studied / IaC Validated] | `compute/compute-decision-matrix.md`, `docs/az900-mapping.md` | Live multi-tier app deployment | Practice scenario questions |
| **Azure Regions & Availability Zones** | Architecture & Services | [Studied / IaC Validated] | `storage/redundancy-matrix.md`, `docs/architecture.md` | Multi-region disaster recovery testing | Study zone-redundant storage models |
| **Resource Groups** | Architecture & Services | [Practical] | `bicep/main.bicep`, `scripts/deploy.sh` | Live subscription creation | Execute when subscription is active |
| **Subscriptions & Management Groups** | Architecture & Services | [Studied / IaC Validated] | `governance/rbac-model.md` | Multi-subscription hierarchy | Diagram enterprise scale landing zones |
| **Virtual Networking (VNet & Subnets)** | Architecture & Services | [Studied / IaC Validated] | `bicep/network.bicep`, `docs/architecture.md` | Live Azure cloud packet flow | Deploy to active tenant |
| **Compute (VMs, VMSS, Containers)** | Architecture & Services | [Studied / IaC Validated] | `compute/bicep/*.bicep`, `compute/compute-decision-matrix.md` | Live cloud deployment pending subscription | Deploy templates upon active subscription |
| **Storage Services (Blob, Files, Tiers)** | Architecture & Services | [Studied / IaC Validated] | `storage/bicep/storage.bicep`, `storage/redundancy-matrix.md` | Live cloud deployment pending subscription | Deploy storage upon active subscription |
| **Microsoft Entra ID** | Architecture & Services | [Studied / IaC Validated] | `docs/identity-and-access.md` | Live tenant administration | Practice Entra user management |
| **MFA & Conditional Access** | Architecture & Services | [Studied / IaC Validated] | `docs/identity-and-access.md` | Live tenant policy simulation | Review Entra P1 licensing scenarios |
| **Azure Role-Based Access Control (RBAC)** | Management & Governance | [Studied / IaC Validated] | `governance/rbac-model.md`, `docs/identity-and-access.md` | Live role assignment assignment | Audit built-in role JSON definitions |
| **Zero Trust Security Model** | Architecture & Services | [Studied / IaC Validated] | `docs/identity-and-access.md` | SIEM / telemetry integration | Review Microsoft Zero Trust guidelines |
| **Microsoft Defender for Cloud** | Architecture & Services | [Gap] | None | Cloud security posture management | Target for Task 012 |
| **Pricing & Cost Management Tools** | Management & Governance | [Studied / IaC Validated] | `docs/cost-control.md` | Live Azure Cost Analysis export | Use Azure Pricing Calculator scenarios |
| **Governance Tags** | Management & Governance | [Practical] | `bicep/network.bicep`, `governance/policies/require-tags.policy.json` | Live tenant policy enforcement | Review policy audit logs |
| **Azure Policy** | Management & Governance | [Practical] | `governance/policies/*.policy.json` | Live policy assignment in tenant | Assign policy to sandbox resource group |
| **Resource Locks** | Management & Governance | [Studied / IaC Validated] | `governance/examples/resource-locks.md` | Live lock override testing | Test CLI lock commands on live group |
| **Azure Portal** | Management & Governance | [Studied / IaC Validated] | `docs/screenshots/azure-network-topology.png` | Ongoing portal navigation | Regular portal walkthroughs |
| **Azure Command Line Interface (CLI)** | Management & Governance | [Practical] | `scripts/deploy.sh`, `scripts/validate.sh` | Advanced JMESPath queries | Practice complex CLI filter queries |
| **Azure PowerShell** | Management & Governance | [Practical] | `powershell/Test-AzureLabEnvironment.ps1`, `powershell/Get-AzureArchitecture.ps1` | Live cloud cmdlet execution | Execute with active context |
| **Azure Arc** | Architecture & Services | [Gap] | None | Hybrid machine onboarding | Target for Task 012 |
| **ARM Templates, Bicep & IaC** | Management & Governance | [Practical] | `bicep/*.bicep`, `compute/bicep/*.bicep`, `storage/bicep/*.bicep` | What-if deployment execution | Integrate into CI/CD GitHub Actions |
| **Azure Advisor** | Management & Governance | [Studied / IaC Validated] | `docs/cost-control.md` | Live advisor recommendation review | Review Advisor recommendation categories |
| **Azure Service Health** | Management & Governance | [Studied / IaC Validated] | `docs/troubleshooting.md` | Service incident notification alert | Configure Service Health alert rules |
| **Azure Monitor & Log Analytics** | Management & Governance | [Gap] | None | KQL queries and workspace ingestion | Target for Task 012 |

---

## Readiness Summary (Post-Task 011)

- **Practical (Local Tooling, Scripts & Validated Configurations)**: 6 competencies
- **Studied / IaC Locally Validated**: 17 competencies
- **Identified Gaps (Roadmap for Task 012)**: 3 competencies
  * Microsoft Defender for Cloud & CSPM
  * Azure Arc (Hybrid Machine Management)
  * Azure Monitor, Log Analytics & KQL Queries

Total competencies evaluated: 26 (100% of official syllabus covered).
