# Azure Compute Infrastructure & IaC Learning Models

Este diretorio contem a modelagem de Infraestrutura como Codigo (Bicep) para servicos de computacao do Microsoft Azure, focando em arquitetura corporativa segura (Zero Ingress publico, NICs privadas e autenticacao baseada em chave publica).

---

## 1. Declaracao de Validacao e Transparencia Operacional

> [!NOTE]
> **Status de Execucao:**
> Todos os templates Bicep contidos nesta pasta foram **desenvolvidos e validados estaticamente em ambiente local** utilizando o compilador oficial da Microsoft (`az bicep build` v0.47.16 com 0 erros).
> 
> **Nenhuma maquina virtual, conjunto de disponibilidade (VMSS) ou container (ACI) foi provisionado em nuvem viva**, uma vez que este ambiente de estudos opera sem associacao de faturamento ativo.

---

## 2. Estrutura do Diretorio

```text
compute/
├── README.md                     # Visao geral arquitetural e governanca de computacao
├── compute-decision-matrix.md    # Matriz comparativa entre servicos de computacao e shared responsibility
└── bicep/
    ├── linux-vm.bicep            # VM Linux Ubuntu com NIC privada e autenticacao SSH
    ├── vm-scale-set.bicep        # Virtual Machine Scale Set (VMSS) em subnet interna
    └── container-instance.bicep  # Azure Container Instance (ACI) educacional
```

---

## 3. Resumo dos Modulos de Computacao

### 3.1. Linux Virtual Machine (`linux-vm.bicep`)
- **Topologia de Rede:** Conectada diretamente a subnet de workload interna (`snet-workload`) da VNet existente (`vnet-core-lab`).
- **Seguranca de Acesso:**
  * **Zero Public IP:** Nenhum endereco IP publico e alocado a interface de rede.
  * **Autenticacao SSH:** Autenticacao por senha desabilitada (`disablePasswordAuthentication: true`), exigindo chave publica SSH (`@secure() param adminSshPublicKey`).
  * **Armazenamento:** Disco gerenciado do sistema operacional (`Standard_LRS`) com exclusao automatica vinculada ao ciclo de vida da maquina (`deleteOption: 'Delete'`).

### 3.2. Virtual Machine Scale Set (`vm-scale-set.bicep`)
- **Proposito:** Modelagem de conjunto de computacao homogeneo para cargas que demandam alta disponibilidade e elasticidade operacional.
- **Capacidade e Escala:** Capacidade inicial parametrizada (`instanceCount` com validacao de range de 1 a 10), permitindo politicas de auto-scaling.
- **Rede e Isolamento:** Cada instancia do conjunto recebe exclusivamente configuracao de IP privado dentro da subnet interna.

### 3.3. Azure Container Instance (`container-instance.bicep`)
- **Proposito:** Demonstracao de execucao de container sob demanda sem necessidade de gerenciamento do servidor ou orquestrador subjacente.
- **Isolamento:** Container group com alocacao definida de CPU (1 core) e memoria (1.5 GB RAM), executando imagem de demonstracao sem necessidade de credenciais de registro privado.

---

## 4. Validacao Estatica Local

Os templates de computacao sao validados localmente com o comando:

```bash
az bicep build --file compute/bicep/linux-vm.bicep
az bicep build --file compute/bicep/vm-scale-set.bicep
az bicep build --file compute/bicep/container-instance.bicep
```
