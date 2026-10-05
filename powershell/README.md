# Azure PowerShell Administration & Diagnostic Lab

Este diretorio contem os recursos, scripts de diagnostico e documentacao para administracao do Microsoft Azure utilizando **PowerShell 7+** e o modulo oficial **Az**.

---

## 1. Declaracao de Seguranca Operacional e Contexto Local

> [!NOTE]
> **Status de Execucao:**
> As ferramentas contidas neste diretorio foram configuradas e testadas **localmente no host operacional**.
> 
> O script `Test-AzureLabEnvironment.ps1` valida a presenca do interpretador PowerShell 7 e dos modulos do Az (`Az.Accounts`, `Az.Resources`, `Az.Network`, `Az.Storage`, `Az.Compute`).
> O script `Get-AzureArchitecture.ps1` implementa verificacao defensiva: caso nao exista sessao ativa autenticada no Azure, ele encerra de forma graciosa e informativa (`[INFO] No active Azure context`), sem gerar erros falsos ou tentar capturar credenciais.

---

## 2. Estrutura do Diretorio

```text
powershell/
├── README.md                      # Visao geral de administracao com PowerShell
├── Test-AzureLabEnvironment.ps1  # Script de diagnostico do ambiente local de ferramentas
├── Get-AzureArchitecture.ps1      # Inspetor arquitetural em PowerShell (equivalente a validate.sh)
└── commands-reference.md          # Matriz comparativa entre comandos Azure CLI e Azure PowerShell
```

---

## 3. Scripts Operacionais

### 3.1. Diagnostico do Ambiente Local (`Test-AzureLabEnvironment.ps1`)
Valida as dependencias tecnicas locais necessarias para automacao em nuvem:
- Verifica se a versao do PowerShell e igual ou superior a 7.0.
- Confirma a disponibilidade dos modulos `Az.Accounts`, `Az.Resources`, `Az.Network`, `Az.Storage` e `Az.Compute`.
- Reporta com seguranca o status da autenticacao Azure.

Execucao:
```bash
pwsh powershell/Test-AzureLabEnvironment.ps1
```

### 3.2. Inspetor de Arquitetura (`Get-AzureArchitecture.ps1`)
Equivalente PowerShell do script Bash `scripts/validate.sh`:
- Inspeciona o contexto via `Get-AzContext`.
- Realiza consultas defensivas e estruturadas sobre Resource Groups, VNets, NSGs, Storage Accounts e VMs.
- Nao tenta realizar alteracoes, atuando estritamente em modo de auditoria de leitura.

Execucao:
```bash
pwsh powershell/Get-AzureArchitecture.ps1 -ResourceGroupName "rg-azure-fundamentals-lab"
```

---

## 4. Referencia de Comandos CLI vs. PowerShell

Para uma comparacao detalhada entre a sintaxe da Azure CLI e do Azure PowerShell, consulte [commands-reference.md](commands-reference.md).
