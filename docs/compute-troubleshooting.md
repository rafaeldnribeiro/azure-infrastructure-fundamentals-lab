# Azure Compute Troubleshooting Runbooks (N2 Support)

Este guia estabelece os procedimentos operacionais padrao de suporte N2 para diagnostico, investigacao e solucao de incidentes criticos envolvendo servicos de computacao no Microsoft Azure (Azure Virtual Machines e VMSS).

---

## Cenario 1: Maquina Virtual Linux nao inicia ou falha no boot

### Sintoma
A VM entra em estado `Failed` de provisionamento ou permanece em loop de inicializacao sem responder a comandos de ligar/reiniciar via Portal ou CLI.

### Hipotese
Falha critica no carregamento do kernel, inconsistencia no sistema de arquivos do disco gerenciado (`osDisk`), corrupcao de configuracao no GRUB ou bloqueio de driver apos atualizacao de kernel.

### Diagnostico
1. Inspecionar o status operacional da VM:
   ```bash
   az vm get-instance-view --resource-group rg-azure-fundamentals-lab --name vm-workload-01 --query "instanceView.statuses" --output table
   ```
2. Coletar o screenshot do console de inicializacao (Boot Diagnostics):
   ```bash
   az vm boot-diagnostics get-boot-log --resource-group rg-azure-fundamentals-lab --name vm-workload-01
   ```
3. Verificar logs seriais para identificar mensagens de panic de kernel ou travamento de servico no `systemd`.

### Causa Provavel
Kernel panic ocasionado por inconsistencia no `/etc/fstab` apos montagem de volume secundario inexistente, ou corrupcao de arquivo durante atualizacao forcada de pacotes.

### Correcao
1. Se o erro for `/etc/fstab`, desacoplar o OS disk da VM afetada.
2. Anexar o disco como data disk em uma VM de recuperacao (rescue VM) na mesma regiao.
3. Montar a particao, corrigir a linha incorreta no `/etc/fstab` inserindo a flag `nofail`.
4. Desmontar, reanexar o disco a VM original e reiniciar a instancia.

### Validacao
```bash
az vm show --resource-group rg-azure-fundamentals-lab --name vm-workload-01 --query "provisioningState" --output tsv
# Deve retornar: Succeeded
```

---

## Cenario 2: Maquina Virtual nao recebe conectividade de rede (Inacessivel)

### Sintoma
A equipe de operacoes nao consegue estabelecer sessao SSH ou comunicacao de rede interna com a maquina virtual na porta 22.

### Hipotese
Regra restritiva no Network Security Group (NSG) associado a subnet ou a NIC, rota incorreta na User Defined Route (UDR) ou falha no servico de rede / DHCP no sistema operacional convidado.

### Diagnostico
1. Testar o fluxo de seguranca com o Azure IP Flow Verify ou inspecionar as regras efetivas de seguranca da interface:
   ```bash
   az network nic show-effective-nsg --resource-group rg-azure-fundamentals-lab --name vm-workload-01-nic --output json
   ```
2. Verificar se a regra de prioridade mais alta esta aplicando `Deny` ao trafego desejado:
   ```bash
   az network nsg rule list --resource-group rg-azure-fundamentals-lab --nsg-name nsg-workload --output table
   ```
3. Verificar a tabela de rotas efetivas para confirmar a presenca de rota padrao para a VNet:
   ```bash
   az network nic show-effective-route-table --resource-group rg-azure-fundamentals-lab --name vm-workload-01-nic --output table
   ```

### Causa Provavel
A regra padrao `DenyAllInbound` com prioridade 65500 esta bloqueando a conexao interna originada da subnet de gerenciamento porque a regra customizada de liberacao possui range de portas ou IPs incorretos.

### Correcao
Ajustar ou criar uma regra de seguranca no NSG permitindo trafego TCP direcionado a porta 22 exclusivamente a partir do prefixo da subnet de gerencia (`10.0.1.0/24`):
```bash
az network nsg rule create \
  --resource-group rg-azure-fundamentals-lab \
  --nsg-name nsg-workload \
  --name allow-mgmt-ssh \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 10.0.1.0/24 \
  --destination-port-ranges 22
```

### Validacao
Reexecutar o teste de conectividade interna ou verificar se as regras efetivas da NIC exibem a nova regra com status `Allow`.

---

## Cenario 3: Falha de Deployment de VM por Quota vs. Capacity

### Sintoma
A tentativa de provisionamento de nova VM ou expansao de VMSS falha imediatamente com codigo `QuotaExceeded` ou `AllocationFailed` / `OverconstrainedAllocationRequest`.

### Hipotese
- Se o erro for `QuotaExceeded`: O limite contratual/administrativo de vCPUs da familia selecionada foi atingido na assinatura para aquela regiao.
- Se o erro for `AllocationFailed`: A infraestrutura fisica de clusters e servidores do Azure na regiao especifica esta temporariamente sem hardware disponivel para alocar o tamanho de VM solicitado.

### Diagnostico
1. Verificar os limites de quota de vCPU da assinatura na regiao:
   ```bash
   az vm list-usage --location brazilsouth --output table
   ```
2. Analisar o log detalhado de erro de deployment:
   * `OperationNotAllowed: Regional quota limit exceeded` -> **Problema de Quota**
   * `AllocationFailed: Azure cannot allocate resources for the requested VM size in this region/cluster` -> **Problema de Capacidade (Capacity)**

### Causa Provavel
- **Quota:** A assinatura de laboratorio possui limite padrao de 10 vCPUs para a familia Standard B-series e a solicitacao tenta alocar 12 vCPUs.
- **Capacity:** Alta demanda temporaria na regiao ou cluster de computacao selecionado para determinado SKU (ex: `Standard_B1s` em uma Zona especifica).

### Correcao
- **Para Quota:**
  * Solicitar aumento de quota pelo portal (Help + Support -> New support request -> Quota).
  * Reduzir o tamanho da VM para um SKU com limite de vCPU disponivel.
- **Para Capacity:**
  * Alterar a familia de VM para um SKU alternativo suportado (ex: de `Standard_B1s` para `Standard_D2s_v5`).
  * Tentar provisionar a maquina em outra Zona de Disponibilidade ou regiao geografica alternativa (ex: `eastus`).

### Validacao
Executar teste de validacao estatica e dry-run do deployment:
```bash
az deployment group validate --resource-group rg-azure-fundamentals-lab --template-file compute/bicep/linux-vm.bicep
```

---

## Cenario 4: Aplicacao precisa escalar alem de uma VM Unica (Gargalo de Recursos)

### Sintoma
A maquina virtual de workload atinge consistentemente 95%+ de utilizacao de CPU e memoria durante picos de demanda, gerando latencia de aplicacao e perda de requisicoes.

### Hipotese
A arquitetura monolitica baseada em VM unica (single-instance) atingiu o teto de escala vertical (scale-up) ou sofre indisponibilidade durante janelas de manutencao do host.

### Diagnostico
1. Verificar metricas historicas de consumo de CPU e memoria no Azure Monitor:
   ```bash
   az monitor metrics list --resource <vm-id> --metric "Percentage CPU" --interval PT5M
   ```
2. Confirmar que a aplicacao pode operar de forma stateless com balanceamento de carga.

### Causa Provavel
Arquitetura IaaS estatica sem suporte a escala horizontal automatica e sem redundancia zonal.

### Correcao
1. Migrar a carga de trabalho de uma VM isolada para um **Virtual Machine Scale Set (VMSS)** (`compute/bicep/vm-scale-set.bicep`).
2. Configurar regras de Auto-scale horizontal baseadas no consumo de CPU (adicionar instancias quando CPU > 75%, remover quando CPU < 30%).
3. Implementar um Azure Load Balancer interno ou Application Gateway para distribuir o trafego entre os nos da escala.

### Validacao
Inspecionar a capacidade e saude das instancias do VMSS:
```bash
az vmss list-instances --resource-group rg-azure-fundamentals-lab --name vmss-workload-lab --output table
```
