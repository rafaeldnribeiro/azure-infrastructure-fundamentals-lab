# Task 011 Readiness Progress & Syllabus Gap Reduction

Este documento registra formalmente a evolucao de competencias tecnicas alcancadas durante a execucao da **Tarefa 011** (Compute, Storage & PowerShell), detalhando a reducao de lacunas no syllabus do exame AZ-900.

---

## 1. Evolucao Quantitativa das Competencias

| Categoria de Status | Pre-Tarefa 011 | Pos-Tarefa 011 | Variacao | Justificativa |
| :--- | :--- | :--- | :--- | :--- |
| **Practical (Local Tooling & IaC Validado)** | 5 | **6** | +1 | Instalacao do PowerShell 7+ e modulo Az com testes locais aprovados (`Test-AzureLabEnvironment.ps1`). |
| **Studied / IaC Locally Validated** | 15 | **17** | +2 | Implementacao e validacao estatica de templates Bicep para VM, VMSS, ACI e Storage Account + runbooks N2. |
| **Gaps Remanescentes** | 6 | **3** | -3 | Compute, Storage e PowerShell foram mitigados atraves de implementacoes e testes locais. |
| **Total de Topicos Monitorados** | 26 | **26** | 0 | Cobertura integral do syllabus oficial 2026. |

---

## 2. Gaps Mitigados na Tarefa 011

1. **Azure Compute Services:**
   - Modelagem de templates Bicep para maquina virtual Linux (`linux-vm.bicep`), conjunto de escala (`vm-scale-set.bicep`) e container sob demanda (`container-instance.bicep`).
   - Matriz de comparacao entre servicos (IaaS vs PaaS vs Serverless vs Containers) e Shared Responsibility Model.
   - Status atualizado: `Studied / IaC Locally Validated`.

2. **Azure Storage Services:**
   - Template Bicep corporativo (`storage.bicep`) com TLS 1.2, HTTPS obrigatorio e bloqueio de acesso anonimo.
   - Matriz comparativa de redundancia (LRS, ZRS, GRS, RA-GRS, GZRS, RA-GZRS).
   - Politica JSON de ciclo de vida (`lifecycle-management.json`) validada com `jq`.
   - Status atualizado: `Studied / IaC Locally Validated`.

3. **Azure PowerShell:**
   - Instalacao do interpretador oficial PowerShell 7.6.5 e modulo Az v16.3.0.
   - Criacao do script de diagnostico local `Test-AzureLabEnvironment.ps1` com 100% de aprovacao nos testes.
   - Criacao do script defensivo `Get-AzureArchitecture.ps1` e guia comparativo de comandos CLI vs PowerShell.
   - Status atualizado: `Practical`.

---

## 3. Gaps Remanescentes para a Tarefa 012

Os tres topicos finais para prontidao completa do syllabus sao:
1. **Microsoft Defender for Cloud & CSPM:** Seguranca em nuvem, recomendacoes do Secure Score e baseline de conformidade.
2. **Azure Arc:** Extensao do plano de controle do Azure para servidores e maquinas on-premises / multi-cloud.
3. **Azure Monitor & Log Analytics:** Telemetria, metricas, alertas e consultas KQL aplicadas a suporte N2.
