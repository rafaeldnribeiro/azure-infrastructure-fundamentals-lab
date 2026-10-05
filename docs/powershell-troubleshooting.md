# Azure PowerShell Troubleshooting Runbooks (N2 Support)

Este guia estabelece os procedimentos operacionais de suporte N2 para diagnostico, investigacao e solucao de problemas na execucao de scripts e administracao do Microsoft Azure via **PowerShell 7+** e modulo **Az**.

---

## Cenario 1: Modulo Az nao encontrado ou erro no carregamento (`Import-Module`)

### Sintoma
Ao tentar executar qualquer cmdlet do Azure (ex: `Get-AzResourceGroup` ou `Connect-AzAccount`), o shell retorna:
`The term 'Get-AzResourceGroup' is not recognized as the name of a cmdlet, function, script file, or operable program.`

### Hipotese
O modulo `Az` nao esta instalado no caminho de modulos padrao do usuario (`$env:PSModulePath`), foi instalado em escopo restrito ou a sessao do terminal nao carregou as variaveis de ambiente atualizadas.

### Diagnostico
1. Inspecionar o `$env:PSModulePath` no PowerShell:
   ```powershell
   $env:PSModulePath -split ':'
   ```
2. Verificar se o modulo existe em disco:
   ```powershell
   Get-Module -ListAvailable -Name Az*
   ```
3. Testar a importacao manual de um submodulo:
   ```powershell
   Import-Module Az.Accounts -Verbose
   ```

### Causa Provavel
O modulo foi instalado via `Scope CurrentUser` sob `~/.local/share/powershell/Modules`, mas uma sessao de terminal iniciada anteriormente nao herdou o caminho ou o snap do PowerShell opera com caminhos isolados.

### Correcao
Adicionar explicitamente o diretorio de modulos do usuario ao `$env:PSModulePath` ou reinstalar com escopo apropriado:
```powershell
if ($env:PSModulePath -notlike "*$HOME/.local/share/powershell/Modules*") {
    $env:PSModulePath = "$HOME/.local/share/powershell/Modules:" + $env:PSModulePath
}
Import-Module Az.Accounts -Force
```

### Validacao
```powershell
Get-Command Get-AzContext
# Deve retornar o comando apontando para o modulo Az.Accounts
```

---

## Cenario 2: Bloqueio por Execution Policy ou Falha de Permissao de Script

### Sintoma
Tentativa de executar um script `.ps1` (como `Test-AzureLabEnvironment.ps1`) falha com:
`File ... cannot be loaded because running scripts is disabled on this system` ou erro de restricao de execucao.

### Hipotese
A politica de execucao do PowerShell (`ExecutionPolicy`) esta configurada como `Restricted` no host.

### Diagnostico
Inspecionar os niveis de politica de execucao em todos os escopos:
```powershell
Get-ExecutionPolicy -List
```

### Causa Provavel
Politica de seguranca padrao em instalacoes Windows ou configuracao herdada de ambiente restrito. No Linux (PowerShell Core), a politica padrao e `Unrestricted`, mas pode ter sido sobrecarregada por arquivo de perfil (`profile.ps1`).

### Correcao
Ajustar a politica de execucao para o escopo do processo atual ou usuario sem comprometer a seguranca global do sistema:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```
Ou executar temporariamente com bypass via linha de comando:
```bash
pwsh -ExecutionPolicy Bypass -File powershell/Test-AzureLabEnvironment.ps1
```

### Validacao
```powershell
Get-ExecutionPolicy
# Deve retornar RemoteSigned ou Unrestricted
```

---

## Cenario 3: Conflito de Versoes do Modulo Az (Multiplas Versoes Instaladas)

### Sintoma
Comandos executam com comportamento inesperado, lancam excecoes de incompatibilidade de assembly .NET (`MethodNotFoundException`) ou avisos de sobreposicao de cmdlets.

### Hipotese
Existem versoes antigas do AzureRM convivendo com o modulo Az, ou multiplas releases do modulo Az instaladas concorrentemente em diretorios compartilhados e locais.

### Diagnostico
Listar todas as versoes instaladas de cada modulo critico:
```powershell
Get-InstalledModule Az.* | Select-Object Name, Version
Get-Module -ListAvailable Az.Accounts | Select-Object Name, Version, Path
```

### Causa Provavel
Atualizacoes parciais ou instalacao manual de pacotes individuais deixaram assemblies de versoes heterogeneas no mesmo ambiente.

### Correcao
1. Remover modulos depreciados do AzureRM (se presentes):
   ```powershell
   Uninstall-AzureRm -ErrorAction SilentlyContinue
   ```
2. Desinstalar versoes obsoletas do Az mantendo apenas a release mais recente:
   ```powershell
   Uninstall-Module -Name Az -AllVersions -Force
   Install-Module -Name Az -Repository PSGallery -Scope CurrentUser -Force
   ```

### Validacao
```powershell
(Get-Module -ListAvailable Az.Accounts).Count
# Deve retornar apenas a versao ativa mais recente
```

---

## Cenario 4: Contexto Vazio (`Get-AzContext` nulo) ou Assinatura Incorreta Selecionada

### Sintoma
Comandos de consulta como `Get-AzResourceGroup` ou `Get-AzVM` retornam:
`Run Connect-AzAccount to login` ou operam sobre a assinatura padrao errada em ambientes multi-tenant/multi-subscription.

### Hipotese
Nao existe token de autenticacao ativo em memoria/cache, a sessao expirou por timeout de MFA, ou o contexto padrao aponta para outra assinatura corporativa.

### Diagnostico
1. Inspecionar o contexto atual de autenticacao:
   ```powershell
   $ctx = Get-AzContext
   if (-not $ctx) { Write-Host "Nenhum contexto ativo" } else { $ctx | Format-List }
   ```
2. Listar as assinaturas acessiveis pela identidade autenticada:
   ```powershell
   Get-AzSubscription | Select-Object Name, Id, State
   ```

### Causa Provavel
- Em ambientes locais de laboratorio sem login ativo, o contexto nulo e o comportamento esperado e seguro.
- Em ambientes de producao, o login foi realizado sem selecionar explicitamente a assinatura de trabalho.

### Correcao
1. Para ambientes sem autenticacao: scripts defensivos devem tratar o contexto como nulo sem gerar crash de pipeline (adotar padrao do `Get-AzureArchitecture.ps1`).
2. Para ambientes conectados: selecionar a assinatura de trabalho correta:
   ```powershell
   Set-AzContext -SubscriptionId "<subscription-id>"
   ```

### Validacao
```powershell
(Get-AzContext).Subscription.Id
# Deve coincidir rigorosamente com a assinatura alvo
```

---

## Cenario 5: Divergencia de Paradigma e Nomenclatura entre Azure CLI e Azure PowerShell

### Sintoma
Analistas habituados com o shell Bash tentam utilizar parametros estilo CLI (`--resource-group`, `--name`) em cmdlets PowerShell ou tentam tratar saidas de objetos .NET como texto plano com `grep`.

### Hipotese
Confusao de sintaxe e arquitetura entre o modelo declarativo/POSIX da CLI (`az`) e o modelo orientado a objetos do PowerShell (`Verbo-Substantivo`).

### Diagnostico
Identificar o comando tentado e comparar com a matriz de equivalencia oficial:
* Erro tipico: `Get-AzVM --resource-group rg-lab` -> Falha de parametro desconhecido.

### Causa Provavel
Desconhecimento da convencao de nomenclatura da Microsoft para PowerShell (`-ResourceGroupName`, `-Name`) ou tentativa de deserializar manualmente JSON em vez de acessar propriedades de objetos.

### Correcao
1. Consultar a referencia oficial em [commands-reference.md](powershell/commands-reference.md).
2. Utilizar autocompletion do PowerShell (`Tab`) e a sintaxe padrao:
   ```powershell
   Get-AzVM -ResourceGroupName "rg-azure-fundamentals-lab" -Name "vm-workload-01"
   ```
3. Utilizar o pipeline para filtrar propriedades de objetos diretamente:
   ```powershell
   Get-AzVM | Where-Object { $_.HardwareProfile.VmSize -eq "Standard_B1s" }
   ```

### Validacao
O cmdlet executa com sucesso retornando objeto formatado sem necessidade de `jq`.
