# 📊 Tech Challenge - Fase 2: Pipeline Híbrido de Dados Educacionais

## 1. Contexto do Problema
A alfabetização na infância é um pilar fundamental para o desenvolvimento educacional, social e econômico do Brasil. Alinhado ao **Compromisso Nacional Criança Alfabetizada**, este projeto analisa o Indicador Criança Alfabetizada, focado no ponto de corte de 743 pontos na escala de proficiência do Saeb, para monitorar a meta de garantir que todas as crianças brasileiras estejam alfabetizadas até o final do 2º ano do ensino fundamental. 

Para compreender as desigualdades educacionais e subsidiar políticas públicas baseadas em evidências, construímos um Data Lakehouse que integra microdados educacionais, metas nacionais/estaduais/municipais e indicadores de desempenho extraídos da **Base dos Dados**.

---

## 2. Arquitetura da Solução
A solução foi desenvolvida na **AWS** seguindo o paradigma **Data Lakehouse** (Arquitetura Medalhão) e um fluxo **Híbrido (Batch + Streaming)**.

* **Ingestão Batch:** Extração periódica de dados históricos (metas educacionais, dados de municípios e resultados agregados), armazenados inicialmente na camada RAW.
* **Ingestão Streaming (Micro-batching):** Simulação de recepção de eventos em tempo quase real (microdados de alunos) via API Gateway e AWS Lambda, salvando arquivos JSON diretamente na camada RAW.
* **Camada Bronze (Raw Data):** Armazenamento de dados brutos sem transformações significativas, preservando o histórico completo.
* **Camada Silver (Dados Tratados):** Limpeza, padronização de tipos e nomes, detecção de valores ausentes e normalização de chaves usando Apache Iceberg.
* **Camada Gold (Camada Analítica):** Criação de datasets prontos para análise (Data Marts), incluindo a evolução temporal do indicador, comparação entre metas e resultados e indicadores de alfabetização por município.

*(Diagrama de Arquitetura)*

---

## 3. Tecnologias Utilizadas e Justificativas
* **AWS S3:** Armazenamento resiliente e de baixo custo para as camadas do Data Lake.
* **Amazon Athena (Engine V3) + Apache Iceberg:** Motor de query *serverless* que possibilita governança e operações transacionais (como `MERGE INTO`), unificando o fluxo batch e streaming sem gerar duplicidade.
* **AWS Step Functions:** Orquestrador *serverless* utilizado para sequenciar a execução do pipeline (Bronze -> Silver -> Gold).
* **AWS Lambda & API Gateway:** Utilizados para construir a rota de ingestão de streaming de forma leve, sem necessidade de instanciar clusters complexos.
* **Python:** Para estruturação dos simuladores locais e processamento de funções Lambda.

---

## 4. Decisões Arquiteturais e Trade-offs
* **Batch vs. Streaming:** Optou-se por um modelo híbrido. Dados de metas anuais rodam em rotinas Batch (baixo custo). Já o envio de informações de alunos exigia menor latência, justificando a adoção de streaming via API. 
* **Data Lake vs. Data Warehouse:** Escolhemos um Data Lakehouse (S3 + Iceberg) ao invés de um DW tradicional (como Redshift) para reduzir drasticamente os custos de armazenamento, mantendo a performance de consulta.
* **Custo vs. Performance:** Todo o ecossistema é *Serverless*. Não há servidores ociosos gerando custos; paga-se apenas pelo tempo de execução e volume de dados escaneados.

---

## 5. Qualidade de Dados e Governança
Implementamos rotinas rigorosas de validação:
* **Validações Blocker:** Verificação de duplicidade, validação de chaves de relacionamento (municípios/órfãos) e consistência entre tabelas (valores percentuais válidos entre 0 e 100).
* **Monitoramento e Alertas:** Rastreamento proativo de regras de negócio, como a sinalização (INFO) da indisponibilidade do detalhamento de níveis de proficiência no ano de 2023.
* **Governança de Código:** Versionamento rigoroso via Git Flow, com separação de *branches* (`feat/...`), uso de Pull Requests e histórico de commits rastreáveis.

---

## 6. FinOps e Otimização de Custos
A arquitetura foi desenhada com foco em eficiência financeira e controle de recursos:

* **Uso Eficiente de Armazenamento:** A conversão de JSON/CSV para o formato **Parquet** na camada Silver reduz o volume de dados em até 80%, diminuindo a fatura de queries do Amazon Athena.
* **Otimização de Queries:** O particionamento dos dados no Iceberg e a execução transacional (`MERGE INTO`) evitam o reprocessamento custoso de tabelas completas.
* **Rastreabilidade por Tagueamento:** Implementação de tags padronizadas em todos os recursos AWS (S3, Lambda, Step Functions e Athena). Isso garante total rastreabilidade da origem dos dados e permite a visão granular dos custos por componente do pipeline.

---

## 7. Aplicação em Inteligência Artificial
A camada Gold foi consolidada em Views Semânticas (`vw_ia_alfabetizacao`) preparadas para algoritmos preditivos e dashboards:
* **Modelos de Predição de Alfabetização:** Com o histórico de resultados e o *gap* em relação às metas, é possível treinar modelos de regressão para prever quais municípios têm maior risco de não atingir os objetivos até 2030.
* **Análise de Desigualdade Educacional:** Algoritmos de *clustering* podem agrupar municípios com perfis semelhantes de vulnerabilidade com base nas taxas de participação e níveis socioeconômicos, direcionando políticas públicas.

---

## 8. Estrutura do Repositório
```text
📦 tech-challenge-fase2-alfabetizacao
 ┣ 📂 .github
 ┃ ┗ 📜 pull_request_template.md
 ┣ 📂 assets
 ┃ ┗ 📜 .gitkeep
 ┣ 📂 data
 ┃ ┗ 📂 amostras
 ┃   ┗ 📜 alunos_streaming.csv
 ┣ 📂 infraestrutura
 ┃ ┣ 📜 01_setup_pastas_s3.py
 ┃ ┣ 📜 02_setup_glue_crawler.py
 ┃ ┣ 📜 03_eventbridge_rule.json
 ┃ ┣ 📜 04_step_function_pipeline_bronze.json
 ┃ ┣ 📜 05_setup_tabelas_bronze.sql
 ┃ ┣ 📜 06_step_function_pipeline_silver.json
 ┃ ┣ 📜 07_step_function_pipeline_gold.json
 ┃ ┣ 📜 08_setup_tabelas_gold.sql
 ┃ ┗ 📜 09_criar_marts.sql
 ┣ 📂 src
 ┃ ┣ 📂 00_ingestao_raw
 ┃ ┃ ┗ 📜 01_extracao_dados.py
 ┃ ┣ 📂 01_camada_bronze
 ┃ ┃ ┣ 📜 01_insert_dicionario.sql
 ┃ ┃ ┣ 📜 02_insert_uf.sql
 ┃ ┃ ┣ 📜 03_insert_municipio.sql
 ┃ ┃ ┣ 📜 04_insert_meta_alfabetizacao_brasil.sql
 ┃ ┃ ┣ 📜 05_insert_meta_alfabetizacao_uf.sql
 ┃ ┃ ┣ 📜 06_insert_meta_alfabetizacao_municipio.sql
 ┃ ┃ ┣ 📜 07_insert_alunos.sql
 ┃ ┃ ┗ 📜 08_bronze_dimensoes.py
 ┃ ┣ 📂 02_camada_silver
 ┃ ┃ ┣ 📜 01_silver_dicionario.py
 ┃ ┃ ┣ 📜 02_silver_uf.py
 ┃ ┃ ┣ 📜 03_silver_municipio.py
 ┃ ┃ ┣ 📜 04_silver_meta_brasil.py
 ┃ ┃ ┣ 📜 05_silver_meta_municipio.py
 ┃ ┃ ┣ 📜 06_silver_meta_uf.py
 ┃ ┃ ┣ 📜 07_silver_alunos.py
 ┃ ┃ ┗ 📜 09_silver_dimensoes.py
 ┃ ┣ 📂 03_camada_gold
 ┃ ┃ ┣ 📜 01_merge_dim_geografia.sql
 ┃ ┃ ┣ 📜 02_merge_dim_rede.sql
 ┃ ┃ ┣ 📜 03_merge_dim_serie.sql
 ┃ ┃ ┣ 📜 04_merge_fato_resultados.sql
 ┃ ┃ ┣ 📜 05_merge_fato_metas.sql
 ┃ ┃ ┗ 📜 06_merge_fato_cobertura.sql
 ┃ ┣ 📂 04_qualidade_dados
 ┃ ┃ ┣ 📜 01_quality_check_silver.sql
 ┃ ┃ ┗ 📜 02_quality_check_gold.sql
 ┃ ┗ 📂 05_streaming
 ┃   ┣ 📜 01_simulador_api.py
 ┃   ┗ 📜 02_ingestao_streaming_raw.py
 ┣ 📜 .gitignore
 ┣ 📜 LICENSE
 ┣ 📜 pyproject.toml
 ┗ 📜 README.md

 