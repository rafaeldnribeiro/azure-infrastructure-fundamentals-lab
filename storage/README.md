# Azure Storage Architecture & Lifecycle Management Lab

Este diretorio contem a modelagem arquitetural e de Infraestrutura como Codigo (Bicep) para servicos de armazenamento do Microsoft Azure (Blob Storage e Azure Files), documentando camadas de acesso (Access Tiers), modelos de redundancia e politicas de ciclo de vida (Lifecycle Management).

---

## 1. Declaracao de Validacao e Transparencia Operacional

> [!NOTE]
> **Status de Execucao:**
> O template Bicep (`storage/bicep/storage.bicep`) e a politica de ciclo de vida (`storage/lifecycle-management.json`) foram **validados estaticamente em ambiente local** utilizando `az bicep build` e `jq empty`.
> 
> **Nenhuma conta de armazenamento (Storage Account), container ou compartilhamento de arquivos foi provisionado na nuvem Azure**, garantindo custo zero e demonstracao segura de capacidade tecnica.

---

## 2. Estrutura do Diretorio

```text
storage/
├── README.md                     # Visao geral, camadas de acesso e casos de uso
├── redundancy-matrix.md          # Matriz comparativa de redundancia (LRS, ZRS, GRS, GZRS)
├── lifecycle-management.json     # Politica demonstrativa de ciclo de vida e transicao de camadas
└── bicep/
    └── storage.bicep             # Template Bicep corporativo para Storage Account (TLS 1.2, Private)
```

---

## 3. Camadas de Acesso (Access Tiers) no Azure Blob Storage

O Azure Storage oferece quatro camadas de acesso a blobs para equilibrar custos de armazenamento em repouso e custos de transacao/recuperacao:

| Camada (Tier) | Frequencia de Acesso | Custo de Armazenamento | Custo de Acesso / Leitura | Disponibilidade e Latencia |
| :--- | :--- | :--- | :--- | :--- |
| **Hot (Frequente)** | Alta (Dados acessados ou modificados frequentemente) | Mais alto | Mais baixo | Latencia de milissegundos; online imediato. |
| **Cool (Esporadico)** | Moderada a Baixa (Acessados com pouca frequencia; retidos por no minimo 30 dias) | Intermediario (menor que Hot) | Intermediario (maior que Hot) | Latencia de milissegundos; online imediato. |
| **Cold (Raro)** | Muito Baixa (Acessados raramente; retidos por no minimo 90 dias) | Baixo (menor que Cool) | Alto | Latencia de milissegundos; online imediato. |
| **Archive (Arquivo)** | Rara / Historica (Dados que quase nunca sao consultados; retidos por no minimo 180 dias) | Minimo (mais barato por GB) | Mais alto de todas as camadas | **Offline**. Requer reidratacao para Hot ou Cool antes da leitura (tempo de horas). |

### Exemplos Praticos de Decisao Arquitetural:
- **Hot Tier:** Logs de auditoria dos ultimos 30 dias, imagens em exibicao ativa em portais web, dados transacionais em processamento.
- **Cool / Cold Tier:** Backups mensais de sistemas legados, imagens de instalacao corporativa acessadas ocasionalmente pelo suporte N2.
- **Archive Tier:** Registros fiscais, prontuarios e logs regulatorios que precisam ser armazenados por 5 anos por requisitos legais de compliance, onde um tempo de reidratacao de algumas horas e plenamente aceitavel.

---

## 4. Gestao Automatizada de Ciclo de Vida (Lifecycle Management)

A politica definida em `storage/lifecycle-management.json` automatiza a reducao de custos operacionais atraves de transicoes orientadas pelo tempo de modificacao dos dados:
1. **Dia 0 a 30:** O dado permanece no **Hot Tier** com maximo desempenho de leitura.
2. **Apos 30 dias:** Transicao automatica para **Cool Tier**, reduzindo a fatura de armazenamento.
3. **Apos 90 dias:** Transicao automatica para **Archive Tier**, garantindo custo residual minimo para retencao historica.
4. **Apos 365 dias:** Exclusao permanente e segura do objeto apos cumprimento do periodo de retencao anual.

---

## 5. Caracteristicas de Hardening do Template Bicep

O template `storage/bicep/storage.bicep` implementa as seguintes regras recomendadas pelo Microsoft Defender for Cloud e CIS Azure Foundations:
- `minimumTlsVersion: 'TLS1_2'`: Bloqueio de conexoes criptograficas depreciadas (TLS 1.0 e 1.1).
- `supportsHttpsTrafficOnly: true`: Exigencia estrita de canais cifrados para qualquer operacao REST.
- `allowBlobPublicAccess: false`: Prevencao contra exposicao publica acidental de containers anonimos.
- `encryption.keySource: 'Microsoft.Storage'`: Criptografia de dados em repouso por padrao com chaves gerenciadas pela plataforma (PMK).
