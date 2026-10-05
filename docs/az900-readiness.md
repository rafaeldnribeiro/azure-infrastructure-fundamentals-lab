# Microsoft Certified: Azure Fundamentals (AZ-900) Readiness Matrix

## Syllabus & Weighting Structure (2026 Syllabus)

The AZ-900 certification exam evaluates competencies across three core functional domains:
- **Domain 1**: Describe cloud concepts (25–30%)
- **Domain 2**: Describe Azure architecture and services (35–40%)
- **Domain 3**: Describe Azure management and governance (30–35%)

---

## Detailed Competency & Gap Analysis Matrix

Classification Key:
- `[Practical]`: Practical code, local implementation, or validated scripts created and tested.
- `[Studied / Documented]`: Conceptual models, architectural documentation, and runbooks established.
- `[Gap]`: Knowledge area identified for upcoming hands-on laboratory iteration.

| Topic / Objective | Functional Domain | Status | Evidence in Repository | Identified Gap | Next Action |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Shared Responsibility Model** | Cloud Concepts | [Studied / Documented] | `docs/architecture.md`, `docs/az900-mapping.md` | Practical audit of security boundaries | Review matrix in practice assessments |
| **Cloud Models (Public/Private/Hybrid)** | Cloud Concepts | [Studied / Documented] | `docs/architecture.md` | Hybrid connectivity lab (VPN gateway) | Study hybrid architecture runbooks |
| **Cloud Service Types (IaaS/PaaS/SaaS)** | Cloud Concepts | [Studied / Documented] | `docs/az900-mapping.md` | Hands-on PaaS database integration | Build PaaS app lab in Task 011 |
| **Azure Regions & Availability Zones** | Architecture & Services | [Studied / Documented] | `bicep/main.bicep` (`brazilsouth`), `docs/architecture.md` | Multi-region disaster recovery testing | Study zone-redundant storage models |
| **Resource Groups** | Architecture & Services | [Practical] | `bicep/main.bicep`, `scripts/deploy.sh` | Live subscription creation | Execute when subscription is active |
| **Subscriptions & Management Groups** | Architecture & Services | [Studied / Documented] | `governance/rbac-model.md` | Multi-subscription hierarchy | Diagram enterprise scale landing zones |
| **Virtual Networking (VNet & Subnets)** | Architecture & Services | [Studied / Documented] | `bicep/network.bicep`, `docs/architecture.md` | Live Azure cloud packet flow | Deploy to active tenant |
| **Compute (VMs, Containers, Functions)** | Architecture & Services | [Gap] | Intentionally excluded to avoid cost | No container or compute lab yet | Build container lab in Task 011 |
| **Storage Services (Blob, Files, Disks)** | Architecture & Services | [Gap] | None | Storage tiers and redundancy models | Create storage account Bicep lab |
| **Microsoft Entra ID** | Architecture & Services | [Studied / Documented] | `docs/identity-and-access.md` | Live tenant administration | Practice Entra user management |
| **MFA & Conditional Access** | Architecture & Services | [Studied / Documented] | `docs/identity-and-access.md` | Live tenant policy simulation | Review Entra P1 licensing scenarios |
| **Azure Role-Based Access Control (RBAC)** | Management & Governance | [Studied / Documented] | `governance/rbac-model.md`, `docs/identity-and-access.md` | Live role assignment assignment | Audit built-in role JSON definitions |
| **Zero Trust Security Model** | Architecture & Services | [Studied / Documented] | `docs/identity-and-access.md` | SIEM / telemetry integration | Review Microsoft Zero Trust guidelines |
| **Microsoft Defender for Cloud** | Architecture & Services | [Gap] | None | Cloud security posture management | Study secure score recommendations |
| **Pricing & Cost Management Tools** | Management & Governance | [Studied / Documented] | `docs/cost-control.md` | Live Azure Cost Analysis export | Use Azure Pricing Calculator scenarios |
| **Governance Tags** | Management & Governance | [Practical] | `bicep/network.bicep`, `scripts/validate.sh` | Policy-enforced automated inheritance | Implement tag inheritance policy |
| **Azure Policy** | Management & Governance | [Practical] | `governance/policies/*.json` | Live policy assignment in tenant | Assign policy to sandbox resource group |
| **Resource Locks** | Management & Governance | [Studied / Documented] | `governance/examples/resource-locks.md` | Live lock override testing | Test CLI lock commands on live group |
| **Azure Portal** | Management & Governance | [Studied / Documented] | `docs/screenshots/azure-network-topology.png` | Ongoing portal navigation | Regular portal walkthroughs |
| **Azure Command Line Interface (CLI)** | Management & Governance | [Practical] | `scripts/deploy.sh`, `scripts/validate.sh` | Advanced JMESPath queries | Practice complex CLI filter queries |
| **Azure PowerShell** | Management & Governance | [Gap] | None | Az PowerShell module commands | Add PowerShell script equivalents |
| **Azure Arc** | Architecture & Services | [Gap] | None | Hybrid machine onboarding | Review Arc-enabled server concepts |
| **ARM Templates, Bicep & IaC** | Management & Governance | [Practical] | `bicep/main.bicep`, `bicep/network.bicep` | What-if deployment execution | Integrate into CI/CD GitHub Actions |
| **Azure Advisor** | Management & Governance | [Studied / Documented] | `docs/cost-control.md` | Live advisor recommendation review | Review Advisor recommendation categories |
| **Azure Service Health** | Management & Governance | [Studied / Documented] | `docs/troubleshooting.md` | Service incident notification alert | Configure Service Health alert rules |
| **Azure Monitor & Log Analytics** | Management & Governance | [Gap] | None | KQL queries and workspace ingestion | Create Log Analytics workspace lab |

---

## Readiness Summary

- **Practical (Local/Static/IaC Implemented)**: 5 competencies
- **Studied / Documented**: 15 competencies
- **Identified Gaps (Roadmap for Task 011+)**: 6 competencies (Compute, Storage, Defender for Cloud, PowerShell, Azure Arc, Azure Monitor)

This matrix establishes the data-driven basis for future learning labs, directly guiding target activities toward full AZ-900 exam readiness.
