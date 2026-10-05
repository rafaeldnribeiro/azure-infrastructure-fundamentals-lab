# Azure Compute Decision Matrix & Architectural Comparison

Este documento estabelece o modelo de tomada de decisao arquitetural para servicos de computacao no Microsoft Azure, mapeando as responsabilidades operacionais, modelos de servico e casos de uso no contexto do exame AZ-900 e de suporte a infraestrutura corporativa.

---

## 1. Matriz Comparativa de Servicos de Computacao

| Servico Azure | Modelo de Servico | Gerencia Sistema Operacional? | Modelo de Escala | Cenario Tipico de Utilizacao |
| :--- | :--- | :--- | :--- | :--- |
| **Azure Virtual Machines (VM)** | IaaS (Infrastructure as a Service) | **Sim** (Cliente responsavel pelo OS, patching e configuracoes) | Manual ou automatica (via VMSS ou regras basicas) | Cargas legadas, controle total do kernel/SO, dependencias customizadas e migracao lift-and-shift. |
| **Virtual Machine Scale Sets (VMSS)** | IaaS (Infrastructure as a Service) | **Sim** (Baseado em imagens customizadas ou marketplace, com gestao de OS) | **Automatica** (Auto-scaling baseado em CPU, memoria ou cronograma) | Conjuntos identicos de VMs para balanceamento de carga, aplicacoes distribuidas de alta disponibilidade e pools de computacao elastica. |
| **Azure App Service** | PaaS (Platform as a Service) | **Nao** (Gerenciado integralmente pela plataforma Azure) | Scale up (CPU/RAM do plano) e Scale out (quantidade de instancias) | Aplicacoes web, APIs REST, servicos backend em .NET, Java, Node.js, Python sem sobrecarga administrativa de SO. |
| **Azure Functions** | Serverless / PaaS | **Nao** (Gerenciado pela plataforma; execucao sem servidor) | Event-driven (Escala instantanea e sob demanda orientada a gatilhos) | Processamento orientado a eventos, integracoes de dados assincronas, micro-tarefas e automacao serverless. |
| **Azure Container Instances (ACI)** | Containers sob demanda / Serverless Containers | **Nao gerencia o host** (Execucao isolada em nivel de container) | Container-level (Escala por inicializacao rapida de novas instancias isoladas) | Execucao rapida de containers isolados sem orquestrador complexo, tarefas em lote (batch jobs) e prototipagem rapida. |
| **Azure Kubernetes Service (AKS)** | Managed Kubernetes (PaaS / CaaS) | **Parcial** (Control plane gerenciado pela Microsoft; nodes de trabalho configuraveis pelo cliente) | Cluster / Workload scaling (Horizontal Pod Autoscaler + Cluster Autoscaler) | Orquestracao de microservicos complexos em larga escala, multi-container, service mesh e portabilidade padrao CNCF. |

---

## 2. Modelo de Responsabilidade Compartilhada (Shared Responsibility Model)

No modelo de computacao em nuvem do Microsoft Azure, a divisao de responsabilidades entre a Microsoft (provedor de nuvem) e o cliente e determinada estritamente pelo modelo de servico adotado (IaaS, PaaS ou SaaS):

### Infraestrutura como Servico (IaaS) - Exemplo: Azure Virtual Machines & VMSS
- **Responsabilidade da Microsoft:** Infraestrutura fisica, seguranca dos datacenters, hardware de servidores, rede fisica, virtualizacao fisica (hipervisor Type-1).
- **Responsabilidade do Cliente:**
  * Escolha, instalacao, hardening e configuracao do Sistema Operacional (Windows ou Linux).
  * Gestao de atualizacoes e patches de seguranca do sistema operacional.
  * Configuracao de firewall de host e Network Security Groups (NSGs).
  * Instalacao, gerenciamento e manutencao de software de aplicacao e runtimes.
  * Gestao de dados, identidade de acesso e contas de administracao local.

### Plataforma como Servico (PaaS) - Exemplo: Azure App Service & Azure Functions
- **Responsabilidade da Microsoft:** Camada fisica, hipervisores, sistema operacional do servidor hospedeiro, aplicacao periodica de patches de SO e manutencao de seguranca da infraestrutura subjacente.
- **Responsabilidade do Cliente:**
  * Codigo da aplicacao, configuracoes do runtime fornecido e bibliotecas de terceiros.
  * Gestao de identidades de acesso (Entra ID, RBAC da aplicacao).
  * Dados da aplicacao e politicas de conformidade.

### Containers como Servico sob Demanda - Exemplo: Azure Container Instances (ACI)
- **Responsabilidade da Microsoft:** Administracao, seguranca e monitoramento do cluster e hosts subjacentes que executam o runtime de containeres. O cliente nao precisa gerenciar maquinas virtuais, patches de kernel do host ou orquestradores subjacentes.
- **Responsabilidade do Cliente:** Seguranca da imagem do container, configuracao das variaveis de ambiente, segredos injetados, limites de recursos (CPU/RAM) e dados manipulados pelo container.

---

## 3. Diretriz de Seguranca Operacional para Cargas IaaS

Para qualquer implementacao de IaaS (Azure VMs):
- Nao associar Public IPs diretamente a adaptadores de rede (NICs) de servidores de carga de trabalho interna.
- Manter portas administrativas (como SSH na porta 22 ou RDP na porta 3389) bloqueadas para acesso direto da Internet.
- Utilizar autenticacao baseada em chave publica SSH com armazenamento seguro ou Azure Bastion para conexoes administrativas seguras.
- Isolar subnets com Network Security Groups (NSGs) configurados sob a abordagem de menor privilegio.
