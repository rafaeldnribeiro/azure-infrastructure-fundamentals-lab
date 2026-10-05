# Azure Cloud Governance & Policy Enforcement

## Architectural Foundation

Cloud governance establishes the guardrails that prevent configuration drift, enforce financial controls, and guarantee security compliance across enterprise environments.

Within Microsoft Azure, governance relies on two complementary, strictly decoupled mechanisms:

```
+--------------------------------------------------------------------------+
|                           AZURE GOVERNANCE                               |
+------------------------------------+-------------------------------------+
|             AZURE RBAC             |            AZURE POLICY             |
|        "WHO CAN DO WHAT"           |     "WHAT RESOURCE STATE IS VALID"  |
+------------------------------------+-------------------------------------+
| • User and Service Principal AuthZ | • Properties, locations & SKU rules |
| • Evaluated at request time        | • Evaluated at provisioning & drift |
| • Scopes: MG > Sub > RG > Resource | • Scopes: MG > Sub > RG > Resource  |
| • Actions: Read, Write, Delete     | • Effects: Deny, Audit, Modify      |
+------------------------------------+-------------------------------------+
```

---

## The Separation of Concerns

### 1. Azure Role-Based Access Control (RBAC)
Azure RBAC controls access by granting users, groups, and service identities permissions across defined scopes.
- Answers the question: *Is this authenticated identity authorized to call the `Microsoft.Network/virtualNetworks/write` API action?*
- Example: An engineer assigned the **Contributor** role on `rg-azure-infra-lab` is authorized to create a Virtual Network.

### 2. Azure Policy
Azure Policy evaluates resource properties and configurations against declared business and security rules.
- Answers the question: *Regardless of who is submitting the request, does the resulting resource comply with company policy (e.g. allowed regions, mandatory tags)?*
- Example: Even if the engineer has **Owner** or **Contributor** rights, Azure Policy with a `Deny` effect will intercept and block the request if the VNet is being provisioned in an unapproved region (e.g. `westeurope` instead of `brazilsouth`).

---

## Directory Structure

```
governance/
├── README.md                      # Governance architecture overview
├── rbac-model.md                  # Conceptual Role-Based Access Control model
├── policies/
│   ├── allowed-locations.policy.json # Restricts resource creation to approved regions
│   └── require-tags.policy.json      # Enforces mandatory governance tags
└── examples/
    └── resource-locks.md          # Accidental deletion prevention via CanNotDelete locks
```
