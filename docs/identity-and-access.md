# Cloud Identity, Access Management & Azure RBAC

## Executive Overview

In cloud architectures, identity is the primary security boundary. Securing cloud resources requires decoupling authentication (verifying identity) from authorization (verifying permissions), backed by continuous verification under the **Zero Trust** model.

This document outlines the identity, authentication, and Role-Based Access Control (RBAC) baseline defined for the **Azure Infrastructure Fundamentals Lab**.

---

## Core Identity Concepts

### 1. Microsoft Entra ID (formerly Azure Active Directory)
Microsoft Entra ID is a multi-tenant, cloud-based identity and access management service. Unlike traditional on-premises Active Directory Domain Services (AD DS) which utilizes Kerberos, NTLM, and LDAP, Microsoft Entra ID uses modern internet protocols:
- SAML 2.0
- OpenID Connect (OIDC)
- OAuth 2.0
- SCIM (System for Cross-domain Identity Management)

### 2. Authentication vs. Authorization
- **Authentication (AuthN)**: Validating *who* the entity is (e.g. username/password, FIDO2 passkey, biometric token).
- **Authorization (AuthZ)**: Determining *what* operations the authenticated entity is permitted to perform against specific resources (e.g. read VNet configurations, restart a service, delete a subnet).

### 3. Multifactor Authentication (MFA) & Passwordless
MFA enforces the presentation of two or more distinct authentication factors:
- Something you know (password, PIN)
- Something you have (hardware token, Microsoft Authenticator push notification, mobile device)
- Something you are (biometrics: fingerprint, facial recognition)

*Passwordless authentication* replaces shared secrets with cryptographic key pairs (FIDO2 security keys, Windows Hello for Business), mitigating phishing and credential stuffing attacks.

### 4. Conditional Access
Conditional Access serves as the intelligent policy evaluation engine. Before granting access, it evaluates real-time signals:
- User or group membership
- IP location or trusted corporate network
- Device health and compliance state (Intune)
- Real-time sign-in risk detection

Enforcement actions include requiring MFA, blocking access entirely, or requiring a managed device.

### 5. Zero Trust Architecture
The operational baseline follows three immutable principles:
1. **Verify Explicitly**: Authenticate and authorize based on all available data points.
2. **Use Least Privilege Access**: Limit user access with Just-In-Time (JIT) and Just-Enough-Access (JEA).
3. **Assume Breach**: Minimize blast radius by segmenting networks, encrypting end-to-end, and continuously analyzing telemetry.

---

## Crucial Distinction: Azure RBAC vs. Microsoft Entra Roles

A fundamental cloud governance principle is understanding the operational plane separation:

| Dimension | Azure RBAC Roles | Microsoft Entra Roles |
| :--- | :--- | :--- |
| **Control Plane** | Azure Resource Manager (ARM) | Microsoft Graph / Identity Plane |
| **Target Scope** | Management Groups, Subscriptions, Resource Groups, Individual Resources | Tenant-wide, User objects, Groups, Enterprise Applications, Domains |
| **Example Built-in Roles** | Owner, Contributor, Reader, Network Contributor | Global Administrator, User Administrator, Helpdesk Administrator |
| **Operational Impact** | Controls creation, update, and deletion of Azure infrastructure (VNets, NSGs, Storage) | Controls password resets, user creation, license assignment, MFA resets |
| **Isolation** | Subscription Owners cannot modify Entra ID users unless assigned an Entra directory role. | Global Administrators do not automatically manage Azure subscriptions unless explicitly elevating access. |

---

## Conceptual Laboratory RBAC Matrix

*Note: The roles below represent the architectural governance model designed for the lab; they are educational blueprints and not declared as assigned on a live corporate tenant.*

| Persona / Responsibility | Target Scope | Assigned Azure Role | Operational Justification |
| :--- | :--- | :--- | :--- |
| **Auditor / Compliance Officer** | Resource Group (`rg-azure-infra-lab`) | **Reader** | Read-only inspection of topology, NSG rules, and activity logs. Absolutely zero permission to create, modify, or delete resources. |
| **Infrastructure Operator (N2 Support)** | Resource Group (`rg-azure-infra-lab`) | **Contributor** | Can provision, modify, and troubleshoot networking, subnets, and automation scripts. Blocked from modifying RBAC permissions or delegating access to others. |
| **Access Administrator** | Subscription or Resource Group | **User Access Administrator** | Manages role assignments and permissions delegations via ARM. Adheres strictly to separation of duties. |
| **Help Desk Analyst** | Resource Group (`rg-azure-infra-lab`) | **Reader + Custom / Specific Action** | Limited strictly to querying network configurations and viewing health logs. Adheres to the Principle of Least Privilege (PoLP). |
