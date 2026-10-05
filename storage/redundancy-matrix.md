# Azure Storage Redundancy Matrix & Replication Models

Este documento detalha os modelos oficiais de redundancia de dados no Microsoft Azure Storage, analisando a resiliencia contra diferentes tipos de falha de infraestrutura, os mecanismos de replicacao sincronos e assincronos, o impacto relativo em custos e os cenarios recomendados para aplicacao corporativa.

---

## 1. Matriz de Resiliencia e Redundancia

| Opcao de Redundancia | Nome Completo | Escopo de Replicacao | Tipo de Replicacao | Resiliencia a Falhas | Custo Relativo | Cenario Recomendado |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **LRS** | Locally Redundant Storage | 3 copias sincronas em um unico datacenter na regiao primaria | Sincrona | Protege contra falhas locais de hardware (disco, rack, servidor). Nao protege contra desastre no datacenter ou zona. | Mais baixo (Baseline) | Ambientes de desenvolvimento, testes, dados temporarios facilmente reproduziveis ou aplicacoes com governanca de dados restrita a um unico local. |
| **ZRS** | Zone-Redundant Storage | 3 copias distribuidas sincronamente entre 3 Zonas de Disponibilidade (AZs) na regiao primaria | Sincrona entre AZs | Protege contra indisponibilidade total de um datacenter ou falha de uma Zona de Disponibilidade inteira. | Moderado | Cargas de trabalho de alta disponibilidade e missao critica que exigem consistencia imediata e tolerancia a falhas zonais sem necessidade de geo-replicacao. |
| **GRS** | Geo-Redundant Storage | 6 copias no total: 3 copias sincronas locais (LRS) na regiao primaria + 3 copias assincronas (LRS) na regiao secundaria (Region Pair) | Sincrona primario / Assincrona secundario | Protege contra indisponibilidade ou desastre geografico de toda a regiao primaria. | Alto | Cargas corporativas com requisitos rigorosos de Recuperacao de Desastres (DR / Business Continuity) tolerando RPO minimo devido a replicacao assincrona. |
| **RA-GRS** | Read-Access Geo-Redundant Storage | Mesma arquitetura do GRS, porem com endpoint dedicado para leitura na regiao secundaria | Sincrona primario / Assincrona secundario | Mesma protecao do GRS, adicionando alta disponibilidade de leitura mesmo sem acionamento formal de failover regional. | Mais alto que GRS | Aplicacoes que demandam leitura continua de dados mesmo em caso de falha de conexao com a regiao primaria, como relatorios e distribuicao de conteudo. |
| **GZRS** | Geo-Zone-Redundant Storage | 6 copias: 3 copias distribuidas entre Zonas de Disponibilidade (ZRS) na regiao primaria + 3 copias assincronas (LRS) na regiao secundaria | Sincrona zonal / Assincrona geo-secundario | Protege simultaneamente contra falha de Zona de Disponibilidade local e desastre regional de larga escala. | Premium | Sistemas corporativos criticos de grande porte que exigem maxima resiliencia zonal no dia a dia somada a protecao geografica para recuperacao de desastres. |
| **RA-GZRS** | Read-Access Geo-Zone-Redundant Storage | Mesma arquitetura do GZRS, com endpoint de leitura ativo na regiao secundaria | Sincrona zonal / Assincrona geo-secundario | Maximo nivel de resiliencia oferecido pelo Azure Storage com leitura geo-distribuida independente de failover. | Maximo | Cargas criticas globais de missao critica extrema com operacao ininterrupta e auditoria continuada. |

---

## 2. Tipos de Falha e Nivel de Protecao

### Falha Fisica Local (Hardware, Rack, Servidor)
- **Cobertura:** Todos os modelos (LRS, ZRS, GRS, RA-GRS, GZRS, RA-GZRS).
- **Mecanismo:** Os dados sao replicados em tres dominios de falha e atualizacao dentro da mesma unidade fisica ou datacenter.

### Falha de Zona (Datacenter Inteiro, Rede Local ou Energia)
- **Cobertura:** ZRS, GZRS, RA-GZRS.
- **Mecanismo:** A replicacao e distribuida entre centros de dados fisicamente separados com suprimento eletrico, refrigeracao e rede independentes dentro da mesma regiao metropolitana.

### Falha Regional (Desastre Natural de Grande Escala, Rompimento de Fibra Transcontinental)
- **Cobertura:** GRS, RA-GRS, GZRS, RA-GZRS.
- **Mecanismo:** Os dados sao replicados assincronamente para uma regiao secundaria pareada (Region Pair), tipicamente localizada a centenas de quilometros de distancia.

---

## 3. Consideracoes Operacionais e de Custo

- **Replicacao Sincrona vs. Assincrona:**
  * Replicacoes locais (LRS) e zonais (ZRS) ocorrem de maneira **sincrona**, garantindo que a escrita so seja confirmada apos o dado ser gravado em todas as replicas locais.
  * Replicacoes geograficas (GRS, GZRS) utilizam replicacao **assincrona** entre regioes para evitar latencias de rede nas gravacoes primarias. Em caso de failover forcado, pode haver um intervalo minimo de perda de dados (Recovery Point Objective - RPO).
- **Otimizacao de Custos:**
  * Para a grande maioria das cargas de desenvolvimento, testes e servidores intermediarios de suporte, o modelo **LRS** oferece o melhor custo-beneficio.
  * Cargas em producao sem necessidade de recuperacao regional devem priorizar **ZRS** para blindagem contra interrupcoes de datacenter sem o custo adicional de trafego geo-replicado.
