# Azure Storage Troubleshooting Runbooks (N2 Support)

Este guia estabelece os procedimentos operacionais de suporte N2 para diagnostico, investigacao e resolucao de incidentes envolvendo o Azure Storage (Blob Storage, Azure Files, autenticacao e conectividade de rede).

---

## Cenario 1: Erro HTTP 403 (Forbidden / AuthorizationFailure) no Acesso a Blobs

### Sintoma
Aplicacoes, analistas ou scripts de backup recebem `HTTP 403 Server failed to authenticate the request` ou `AuthorizationPermissionMismatch` ao tentar ler ou gravar dados no container de blobs.

### Hipotese
Incompatibilidade no mecanismo de autenticacao (RBAC vs. Access Keys vs. SAS Token), expiracao ou escopo incorreto de Shared Access Signature (SAS), ou ausencia de permissao no plano de dados (`Storage Blob Data Contributor` / `Reader`).

### Diagnostico
1. Inspecionar o metodo de autenticacao utilizado pelo cliente:
   * Se utiliza Microsoft Entra ID (RBAC), verificar atribuicoes no escopo do Storage Account ou Container:
     ```bash
     az role assignment list --scope <storage-account-id> --output table
     ```
   * Se utiliza SAS Token: decodificar os parametros da query string:
     - `se` (signed expiry): verificar se o token expirou (comparar com UTC).
     - `sp` (signed permissions): verificar se contem as acoes requeridas (`r` para leitura, `w` para escrita).
     - `sr` (signed resource): verificar se o escopo cobre container (`c`) ou blob (`b`).
2. Verificar se o Storage Account possui `allowSharedKeyAccess: false` desabilitado, forcando exclusivamente autenticacao via Entra ID.

### Causa Provavel
O usuario possui papel RBAC de gerenciamento (`Contributor` no Resource Group), mas nao possui papel RBAC no **plano de dados** (`Storage Blob Data Contributor`), gerando erro 403 mesmo com permissoes administrativas no portal.

### Correcao
Atribuir o papel RBAC correto de plano de dados seguindo o principio do menor privilegio:
```bash
az role assignment create \
  --assignee <user-or-sp-object-id> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/<sub-id>/resourceGroups/rg-azure-fundamentals-lab/providers/Microsoft.Storage/storageAccounts/<account-name>/blobServices/default/containers/data-archive
```

### Validacao
Executar teste de leitura/escrita via Azure CLI com autenticacao de login:
```bash
az storage blob list --account-name <account-name> --container-name data-archive --auth-mode login --output table
```

---

## Cenario 2: Storage Account nao aceita configuracao ou bloqueia criacao de container

### Sintoma
Tentativas de criar novos containers, alterar o nivel de TLS ou modificar regras de rede falham com erro `RequestDisallowedByPolicy` ou `AccountNameInvalid`.

### Hipotese
Violacao de regra do Azure Policy (ex: `require-tags` ou `allowed-locations`), ou tentativa de utilizar nome de Storage Account que nao atende aos padroes globais de nomenclatura.

### Diagnostico
1. Verificar os requisitos de nome do Azure Storage:
   * Unico globalmente entre todos os clientes Azure no mundo.
   * Apenas letras minusculas e numeros (3 a 24 caracteres, sem tracos ou sublinhados).
2. Verificar politicas de conformidade ativas que possam estar bloqueando o provisionamento:
   ```bash
   az policy assignment list --resource-group rg-azure-fundamentals-lab --output table
   ```

### Causa Provavel
O template Bicep ou comando CLI utilizou caracteres especiais no nome da conta (como `stg_lab-01`) ou o deployment nao incluiu as tags corporativas obrigatorias (`environment`, `project`, `owner`).

### Correcao
1. Utilizar funcao `uniqueString(resourceGroup().id)` para gerar sufixo compativel e unico sem caracteres especiais.
2. Garantir a declaracao das tags exigidas no bloco de propriedades do recurso.

### Validacao
```bash
az storage account check-name --name <proposed-name> --output table
# NameAvailable deve retornar True
```

---

## Cenario 3: Blobs inacessiveis por Bloqueio de Rede (Firewall) ou Acesso Publico Desabilitado

### Sintoma
Usuarios externos ou sistemas on-premises nao conseguem baixar arquivos estaticos atraves do endpoint HTTPS publico do blob, recebendo erro `PublicAccessNotPermitted` ou timeout de conexao.

### Hipotese
A diretiva corporativa de seguranca `allowBlobPublicAccess: false` esta ativa na conta, ou as regras de Storage Firewall estao restringindo o acesso exclusivamente a VNets autorizadas ou IPs especificos.

### Diagnostico
1. Inspecionar a configuracao de acesso publico da conta:
   ```bash
   az storage account show --name <account-name> --resource-group rg-azure-fundamentals-lab --query "{PublicAccess:allowBlobPublicAccess, NetworkAcls:networkAcls}" --output json
   ```
2. Verificar se `networkAcls.defaultAction` esta configurado como `Deny` sem incluir a rede de origem do cliente.

### Causa Provavel
Seguranca defensiva aplicada por padrao: o blob foi criado em um container com politica de acesso anonimo desabilitada e firewall de rede ativo.

### Correcao
1. Se o acesso deve ser privado corporativo: utilizar **Private Endpoints** integrados a Virtual Network ou conectar via VPN corporativa.
2. Se o acesso publico for um requisito de negocio aprovado: habilitar `allowBlobPublicAccess: true` na conta e configurar o container correspondente com nivel de acesso anonimo controlado, ou preferencialmente emitir SAS Tokens temporarios com tempo de vida restrito.

### Validacao
Testar a resolucao DNS e comunicacao via curl contra o endpoint protegido:
```bash
curl -I https://<account-name>.blob.core.windows.net/data-archive/sample.txt
```

---

## Cenario 4: Escolha Inadequada de Redundancia ou Camada de Acesso (Tier) gerando Custos Elevados ou Latencia

### Sintoma
A fatura mensal da assinatura apresenta custos desproporcionais de operacoes de gravacao/leitura no Storage, ou aplicacoes sofrem indisponibilidade durante manutencao de datacenter na regiao.

### Hipotese
- Cargas de dados temporarios de teste foram configuradas erroneamente com replicacao geo-redundante (`Standard_GRS` ou `GZRS`), gerando faturamento de transferencia de dados desnecessario.
- Dados acessados diariamente foram gravados no **Archive Tier** ou **Cold Tier**, gerando altas taxas por transacao de leitura e demora extrema para liberacao de leitura.

### Diagnostico
1. Analisar a camada de acesso de cada blob e o SKU de redundancia da conta:
   ```bash
   az storage account show --name <account-name> --query "sku" --output json
   az storage blob list --account-name <account-name> --container-name data-archive --query "[].{Name:name, Tier:properties.accessTier}" --output table
   ```

### Causa Provavel
Falta de alinhamento entre o padrao de consumo dos dados e a matriz arquitetural de camadas do Azure Storage.

### Correcao
1. Alterar o SKU da conta de desenvolvimento/teste de `Standard_GRS` para `Standard_LRS` para reducao imediata de custo base.
2. Reidratar blobs acessados com frequencia para o **Hot Tier**:
   ```bash
   az storage blob set-tier --account-name <account-name> --container-name data-archive --name sample.txt --tier Hot
   ```
3. Implementar regras de ciclo de vida (`storage/lifecycle-management.json`) para automatizar transicoes de dados inativos para Cool e Archive sem intervencao manual.

### Validacao
Verificar no Azure Cost Management o impacto projetado da reducao de custos e monitorar tempos de resposta de leitura da aplicacao.
