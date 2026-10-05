# Microsoft Azure Fundamentals (AZ-900) - Practical Competency Mapping

## Overview

This document demonstrates how the hands-on tasks executed in the **Azure Infrastructure Fundamentals Lab** directly validate the official knowledge domains defined in the **Microsoft Certified: Azure Fundamentals (AZ-900)** exam syllabus.

---

## Domain Alignment Matrix

| AZ-900 Functional Domain | Lab Implementation | Evidence in Code / Artifacts |
| :--- | :--- | :--- |
| **Describe Cloud Concepts** | Application of the Cloud Consumption Model, CapEx vs. OpEx considerations, and Shared Responsibility. | [Cost Control Guide](cost-control.md), zero-chargeable architecture design. |
| **Azure Architecture Components** | Provisioning resources in the `brazilsouth` datacenter region within a dedicated Resource Group container. | `bicep/main.bicep` parameters (`location: 'brazilsouth'`), `rg-azure-infra-lab`. |
| **Core Networking Services** | Custom Virtual Network (`vnet-infra-lab`, `10.20.0.0/16`) segmented into Management and Workload subnets. | `bicep/network.bicep` (`Microsoft.Network/virtualNetworks`). |
| **Subnet Partitioning & CIDR** | Mathematical allocation of non-overlapping CIDR blocks (`10.20.1.0/24` and `10.20.2.0/24`), reserving Azure-specific IPs. | `bicep/network.bicep` subnets block, `scripts/validate.sh`. |
| **Network Security Groups (NSGs)** | Layer-4 stateful packet filtering, rule priority hierarchies (1000 vs. 4000), default deny internet inbound. | `bicep/network.bicep` (`Microsoft.Network/networkSecurityGroups`). |
| **Azure Resource Manager (ARM)** | Declarative template engine parsing resource dependencies, idempotency guarantees, and pre-flight `what-if` analysis. | `scripts/deploy.sh` invoking `az deployment group what-if`. |
| **Infrastructure as Code (IaC)** | Modular Bicep definitions, strongly-typed parameters, compile-time validation, and parameter files (`.bicepparam`). | `bicep/main.bicep`, `bicep/network.bicep`, `bicep/main.bicepparam`. |
| **Azure Command Line Interface (CLI)** | Automated provisioning, querying, JSON parsing via JMESPath, and compliance verification using `az` commands. | `scripts/deploy.sh`, `scripts/validate.sh`, `scripts/destroy.sh`. |
| **Governance & Resource Tagging** | Applying standardized metadata tags for project attribution, environment scoping, and IaC tracking. | `tags` object in `bicep/main.bicep` verified by `scripts/validate.sh`. |
| **Resource Lifecycle Management** | Controlled, programmatic creation, verification, and non-destructive teardown workflows. | Automated script toolchain under `scripts/`. |

---

## Key Theoretical Distinctions Demonstrated

### 1. IaaS vs. PaaS in Network Foundations
While VNets represent Infrastructure as a Service (IaaS) boundary management, the underlying software-defined network (SDN) is managed as a platform capability by Azure, eliminating the need to configure physical switch fabrics, patch panel VLANs, or optical transceivers.

### 2. Stateful Filtering in NSGs
Azure NSGs are stateful firewalls: when an inbound packet is permitted, the return outbound traffic is automatically tracked and allowed regardless of outbound security rules, maintaining session consistency.

### 3. Shared Responsibility Model
- **Microsoft Responsibilities**: Physical datacenter security, hypervisor isolation, underlying physical switches, fiber backbones, and hardware power redundancy.
- **Customer Responsibilities**: Network segmentation, routing table configurations, subnet IP allocation, NSG firewall rules, and access control policies.
