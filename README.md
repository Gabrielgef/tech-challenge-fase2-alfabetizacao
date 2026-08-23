# Tech Challenge - Fase 2: Arquitetura de Dados de Alfabetização

Este repositório contém a implementação de um Data Lake (Arquitetura Medalhão) focado em dados de alfabetização do Inep, utilizando serviços AWS (S3, Athena, Glue, Step Functions e EventBridge) e orquestração orientada a eventos (Event-Driven).

## 🗂️ Estrutura do Repositório

    ├── .github/
    ├── infraestrutura/
    │   ├── 01_setup_pastas_s3.py
    │   ├── 02_setup_glue_crawler.py
    │   ├── 03_eventbridge_rule.json
    │   ├── 04_step_function_pipeline.json
    │   └── 05_setup_tabelas_bronze.sql
    ├── src/
    │   ├── camada_bronze/
    │   │   ├── 01_insert_dicionario.sql
    │   │   ├── 02_insert_uf.sql
    │   │   ├── 03_insert_municipio.sql
    │   │   ├── 04_insert_meta_alfabetizacao_brasil.sql
    │   │   ├── 05_insert_meta_alfabetizacao_uf.sql
    │   │   ├── 06_insert_meta_alfabetizacao_municipio.sql
    │   │   └── 07_insert_alunos.sql
    │   └── ingestao_raw/
    │       └── 01_extracao_dados.py
    ├── .env.example
    ├── .gitignore
    ├── pyproject.toml
    └── README.md

## 🛠️ Pré-requisitos

Antes de executar os scripts, garanta que seu ambiente possui:

1. **Python 3.9+** e dependências instaladas (via `pyproject.toml`).
2. **AWS CLI** instalado e configurado (`aws configure`) com as credenciais da sua LabRole.
3. **Google Cloud Platform (GCP):** Um ID de projeto válido (`billing_project_id`) para consultar a Base dos Dados via BigQuery.
4. **Arquivo .env**: Faça uma cópia do arquivo `.env.example`, renomeie para `.env` e preencha as variáveis de ambiente necessárias:
   * `AWS_ACCOUNT_ID`: Seu ID da conta AWS.
   * `BILLING_PROJECT_ID`: Seu ID de projeto do Google Cloud.
   * `NOME_DO_BUCKET`: O nome escolhido para o seu bucket S3.

---

## 🏗️ Passo 1: Setup da Infraestrutura (IaC)

A infraestrutura deve ser provisionada uma única vez antes de qualquer ingestão de dados. 

### 1.1. Criação das Camadas no S3
Gera a estrutura física do Data Lake.

    python infraestrutura/01_setup_pastas_s3.py

### 1.2. Configuração do Glue Crawler
Cria o banco `db_raw_alfabetizacao` e provisiona o Crawler.

    python infraestrutura/02_setup_glue_crawler.py

### 1.3. Orquestração (Step Functions e EventBridge)
1. Acesse o AWS Step Functions e crie uma nova Máquina de Estados colando o conteúdo de `infraestrutura/04_step_function_pipeline.json`.
2. Acesse o Amazon EventBridge e crie uma regra apontando para o arquivo `infraestrutura/03_eventbridge_rule.json`. Isso garante que o pipeline inicie apenas após a criação do arquivo `_SUCCESS.flag`.

### 1.4. Setup da Camada Bronze (Athena DDL)
1. Abra o console do Amazon Athena.
2. Copie o conteúdo de `infraestrutura/05_setup_tabelas_bronze.sql`.
3. Selecione e execute cada bloco individualmente para provisionar as 7 tabelas.

---

## 🚀 Passo 2: Execução e Ingestão de Dados

### Ingestão Raw
O script abaixo conecta ao BigQuery via API da Base dos Dados, extrai os CSVs e faz o upload para o S3.

**Nota sobre execução:** Caso não tenha o Google Cloud SDK configurado no seu ambiente local, recomenda-se rodar o conteúdo do arquivo `01_extracao_dados.py` no Google Colab para facilitar a autenticação do usuário.

    python src/ingestao_raw/01_extracao_dados.py

**O Fluxo Automatizado:**
Ao finalizar o upload, o script gera um `_SUCCESS.flag`. O EventBridge intercepta esse evento e dispara o Step Functions. O pipeline atualizará a Raw via Crawler e executará as queries da pasta `src/camada_bronze/`, populando as tabelas particionadas no S3.

