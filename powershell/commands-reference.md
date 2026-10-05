# Azure CLI vs. Azure PowerShell: Comparative Reference & Operations

Este documento estabelece uma comparacao tecnica entre a interface de linha de comando oficial da Microsoft (**Azure CLI**) e o modulo administrativo **Azure PowerShell (Az)**, analisando paradigmas de execucao, casos de uso operacionais e correspondencia de comandos essenciais para administracao de nuvem.

---

## 1. Tabela Comparativa de Comandos Operacionais

| Operacao de Administracao | Comando Equivalente na Azure CLI | Cmdlet Equivalente no Azure PowerShell |
| :--- | :--- | :--- |
| **Exibir Conta / Contexto Ativo** | `az account show` | `Get-AzContext` |
| **Listar Assinaturas Disponiveis** | `az account list --output table` | `Get-AzSubscription` |
| **Listar Grupos de Recursos** | `az group list --output table` | `Get-AzResourceGroup` |
| **Criar Grupo de Recursos** | `az group create --name <rg> --location <loc>` | `New-AzResourceGroup -Name <rg> -Location <loc>` |
| **Listar Redes Virtuais (VNets)** | `az network vnet list --output table` | `Get-AzVirtualNetwork` |
| **Listar Network Security Groups (NSGs)**| `az network nsg list --output table` | `Get-AzNetworkSecurityGroup` |
| **Listar Maquinas Virtuais (VMs)** | `az vm list --output table` | `Get-AzVM` |
| **Iniciar / Parar VM** | `az vm start` / `az vm deallocate` | `Start-AzVM` / `Stop-AzVM` |
| **Listar Contas de Armazenamento** | `az storage account list --output table` | `Get-AzStorageAccount` |
| **Listar Blobs em um Container** | `az storage blob list --container-name <c>` | `Get-AzStorageBlob -Container <c>` |
| **Implantar Template Bicep** | `az deployment group create --template-file ...` | `New-AzResourceGroupDeployment -TemplateFile ...` |

---

## 2. Paradigmas de Funcionamento e Arquitetura

### Azure CLI (`az`)
- **Natureza:** Ferramenta multiplataforma desenvolvida primariamente em Python, estruturada em comandos hierarquicos e flags (padrao POSIX).
- **Tratamento de Saida:** Retorna dados estruturados em formato texto, tabela ou **JSON** nativo.
- **Filtragem e Pipeline:** Realizada via argumentos JMESPath integrados (`--query "[?location=='brazilsouth']"`) ou combinada no shell Bash com utilitarios como `grep`, `awk`, `cut` e `jq`.
- **Pontos Fortes:** Excelente para automacoes em ambientes Linux, pipelines de CI/CD (GitHub Actions, GitLab CI), scripts Bash compactos e facilidade de portabilidade entre diferentes sistemas operacionais.

### Azure PowerShell (`Az Module`)
- **Natureza:** Modulo para PowerShell (Core / PowerShell 7+), estruturado segundo a convencao rigorosa `Verbo-Substantivo` (`Get-`, `New-`, `Set-`, `Remove-`).
- **Tratamento de Saida:** Retorna **objetos .NET tipados em memoria**, e nao fluxos de texto bruto serializado.
- **Filtragem e Pipeline:** Realizada atraves do pipeline do PowerShell (`|`), operando diretamente sobre propriedades e metodos dos objetos (`Where-Object`, `Select-Object`, `ForEach-Object`) sem necessidade de parsing de strings ou conversoes intermediarias.
- **Pontos Fortes:** Integracao profunda com o ecossistema corporativo Microsoft (Active Directory, Windows Server, scripts corporativos em PowerShell), encadeamento robusto de acoes administrativas complexas e tratamento nativo de excecoes tipadas.

---

## 3. Diretriz de Escolha Operacional

Ambas as ferramentas sao oficialmente suportadas e mantidas pela Microsoft com cobertura equivalente das APIs do Azure Resource Manager (ARM):
- Nao existe uma ferramenta universalmente superior; a escolha e determinada pelo **ecossistema de execucao** e pelas **necessidades da equipe**:
  * Em estacoes Linux e servidores de automacao com pipelines baseados em containers e scripts de shell, a **Azure CLI** oferece execucao direta e leve.
  * Em ambientes corporativos centrados no gerenciamento de servidores Windows, suporte a estacoes de trabalho empresariais e integracao com scripts PowerShell legados, o **Azure PowerShell** proporciona produtividade e controle de tipos superior.
