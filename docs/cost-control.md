# Cloud Cost Control & Financial Guardrails

## Financial Safety Baseline

A primary engineering principle of the **Azure Infrastructure Fundamentals Lab** is **Zero Ongoing Financial Exposure**.

Cloud learning and portfolio demonstration must adhere to strict financial governance, avoiding unexpected runaway cloud bills while validating practical networking, IaC, and security architectures.

---

## Resource Inclusions vs. Exclusions

| Architecture Component | Status | Pricing Impact | Rationale |
| :--- | :--- | :--- | :--- |
| **Virtual Network (VNet)** | Deployed | $0.00 / month | VNets have no base hourly fee in Azure. Up to 50 VNets per subscription are free. |
| **Subnets** | Deployed | $0.00 / month | Logical partitioning within a VNet has no associated cost. |
| **Network Security Groups (NSGs)** | Deployed | $0.00 / month | Standard stateful NSGs carry zero hourly fee and zero rule-evaluation surcharge. |
| **Bicep IaC Templates** | Deployed | $0.00 / month | ARM engine and Bicep execution are free platform capabilities. |
| **Virtual Machines (Compute)** | **EXCLUDED** | Avoided ~$15-$60/mo | Compute workloads are simulated through network boundaries; no compute hours billed. |
| **Public IP Addresses** | **EXCLUDED** | Avoided ~$3.65/mo per IP | Zero ingress architecture prevents unnecessary public allocation charges. |
| **VPN / NAT Gateway** | **EXCLUDED** | Avoided ~$32-$140/mo | Gateways bill hourly even when idle. Internal mesh overlays are used instead. |
| **Application Gateway / Firewall** | **EXCLUDED** | Avoided ~$180-$900/mo | High-cost enterprise appliances omitted from foundational lab. |
| **Managed Databases (SQL / Cosmos)** | **EXCLUDED** | Avoided ~$15-$300/mo | Relational/NoSQL engines are not required for network infrastructure validation. |

---

## Real-Time Cost Auditing Commands

To verify that zero chargeable compute or network gateway resources exist in the environment:

```bash
# List all resources in the lab resource group with their respective resource types
az resource list --resource-group rg-azure-infra-lab --output table

# Verify absence of virtual machines
az vm list --resource-group rg-azure-infra-lab --output table

# Verify absence of public IP allocations
az network public-ip list --resource-group rg-azure-infra-lab --output table

# Audit current billing cost accumulation for the resource group
az consumption usage list \
  --start-date "$(date +%Y-%m-01)" \
  --end-date "$(date +%Y-%m-%d)" \
  --query "[?contains(instanceName, 'rg-azure-infra-lab')]" \
  -o table 2>/dev/null || echo "No billable consumption recorded."
```

---

## Teardown Lifecycle Guarantee

The included script `scripts/destroy.sh` provides deterministic, interactive removal of all lab assets:

```bash
./scripts/destroy.sh rg-azure-infra-lab
```

By encapsulating all resources within `rg-azure-infra-lab`, cloud engineers ensure no orphaned resources or lingering IP reservations remain to generate downstream costs.
