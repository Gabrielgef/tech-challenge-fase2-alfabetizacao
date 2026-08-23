-- ==========================================
-- TABELA 1: ALUNOS
-- ==========================================
CREATE TABLE db_bronze_alfabetizacao.alunos
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://<NOME_DO_SEU_BUCKET>/bronze/alunos/',
) AS
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.alunos
WHERE 1=0;

-- ==========================================
-- TABELA 2: DICIONARIO
-- ==========================================
CREATE TABLE db_bronze_alfabetizacao.dicionario
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://<NOME_DO_SEU_BUCKET>/bronze/dicionario/',
) AS
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.dicionario
WHERE 1=0;

-- ==========================================
-- TABELA 3: META ALFABETIZACAO BRASIL
-- ==========================================
CREATE TABLE db_bronze_alfabetizacao.meta_alfabetizacao_brasil
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://<NOME_DO_SEU_BUCKET>/bronze/meta_alfabetizacao_brasil/',
) AS
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.meta_alfabetizacao_brasil
WHERE 1=0;

-- ==========================================
-- TABELA 4: META ALFABETIZACAO MUNICIPIO
-- ==========================================
CREATE TABLE db_bronze_alfabetizacao.meta_alfabetizacao_municipio
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://<NOME_DO_SEU_BUCKET>/bronze/meta_alfabetizacao_municipio/',
) AS
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.meta_alfabetizacao_municipio
WHERE 1=0;

-- ==========================================
-- TABELA 5: META ALFABETIZACAO UF
-- ==========================================
CREATE TABLE db_bronze_alfabetizacao.meta_alfabetizacao_uf
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://<NOME_DO_SEU_BUCKET>/bronze/meta_alfabetizacao_uf/',
) AS
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.meta_alfabetizacao_uf
WHERE 1=0;

-- ==========================================
-- TABELA 6: MUNICIPIO
-- ==========================================
CREATE TABLE db_bronze_alfabetizacao.municipio
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://<NOME_DO_SEU_BUCKET>/bronze/municipio/',
) AS
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.municipio
WHERE 1=0;

-- ==========================================
-- TABELA 7: UF
-- ==========================================
CREATE TABLE db_bronze_alfabetizacao.uf
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://<NOME_DO_SEU_BUCKET>/bronze/uf/',
) AS
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.uf
WHERE 1=0;