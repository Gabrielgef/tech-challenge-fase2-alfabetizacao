-- Executar uma única vez no Athena Engine 3.
-- Substituir <BUCKET> pelo bucket real antes da implantação.

CREATE DATABASE IF NOT EXISTS db_bronze_alfabetizacao;

CREATE EXTERNAL TABLE IF NOT EXISTS db_bronze_alfabetizacao.alunos(
  ano bigint, 
  id_municipio bigint, 
  id_escola bigint, 
  id_aluno bigint, 
  caderno bigint, 
  serie bigint, 
  rede bigint, 
  presenca bigint, 
  preenchimento_caderno bigint, 
  alfabetizado bigint, 
  proficiencia double, 
  peso_aluno double, 
  data_ingestao timestamp
  )
LOCATION
  's3://<BUCKET_S3>/bronze/alunos/'
TBLPROPERTIES (
  'format' = 'parquet',
  'write_compression' = 'snappy'
);

CREATE EXTERNAL TABLE IF NOT EXISTS db_bronze_alfabetizacao.dicionario(
  id_tabela string, 
  nome_coluna string, 
  chave bigint, 
  cobertura_temporal string, 
  valor string, 
  data_ingestao timestamp
  )
LOCATION
  's3://<BUCKET_S3>/bronze/dicionario/'
TBLPROPERTIES (
  'format' = 'parquet',
  'write_compression' = 'snappy'
);

CREATE EXTERNAL TABLE IF NOT EXISTS db_bronze_alfabetizacao.meta_alfabetizacao_brasil(
  ano bigint, 
  rede string, 
  taxa_alfabetizacao double, 
  meta_alfabetizacao_2024 double, 
  meta_alfabetizacao_2025 double, 
  meta_alfabetizacao_2026 double, 
  meta_alfabetizacao_2027 double, 
  meta_alfabetizacao_2028 double, 
  meta_alfabetizacao_2029 double, 
  meta_alfabetizacao_2030 double, 
  percentual_participacao double, 
  data_ingestao timestamp
  )
LOCATION
  's3://<BUCKET_S3>/bronze/meta_alfabetizacao_brasil/'
TBLPROPERTIES (
  'format' = 'parquet',
  'write_compression' = 'snappy'
);

CREATE EXTERNAL TABLE IF NOT EXISTS db_bronze_alfabetizacao.meta_alfabetizacao_municipio(
  ano bigint, 
  id_municipio bigint, 
  rede string, 
  taxa_alfabetizacao double, 
  meta_alfabetizacao_2024 double, 
  meta_alfabetizacao_2025 double, 
  meta_alfabetizacao_2026 double, 
  meta_alfabetizacao_2027 double, 
  meta_alfabetizacao_2028 double, 
  meta_alfabetizacao_2029 double, 
  meta_alfabetizacao_2030 double, 
  nivel_alfabetizacao bigint, 
  percentual_participacao double, 
  data_ingestao timestamp
  )
LOCATION
  's3://<BUCKET_S3>/bronze/meta_alfabetizacao_municipio/'
TBLPROPERTIES (
  'format' = 'parquet',
  'write_compression' = 'snappy'
);

CREATE EXTERNAL TABLE IF NOT EXISTS db_bronze_alfabetizacao.meta_alfabetizacao_uf(
  ano bigint, 
  sigla_uf string, 
  rede string, 
  taxa_alfabetizacao double, 
  meta_alfabetizacao_2024 double, 
  meta_alfabetizacao_2025 double, 
  meta_alfabetizacao_2026 double, 
  meta_alfabetizacao_2027 double, 
  meta_alfabetizacao_2028 double, 
  meta_alfabetizacao_2029 double, 
  meta_alfabetizacao_2030 double, 
  percentual_participacao double, 
  data_ingestao timestamp
  )
LOCATION
  's3://<BUCKET_S3>/bronze/meta_alfabetizacao_uf/'
TBLPROPERTIES (
  'format' = 'parquet',
  'write_compression' = 'snappy'
);

CREATE EXTERNAL TABLE IF NOT EXISTS db_bronze_alfabetizacao.municipio(
  ano bigint, 
  id_municipio bigint, 
  serie bigint, 
  rede bigint, 
  taxa_alfabetizacao double, 
  media_portugues double, 
  proporcao_aluno_nivel_0 string, 
  proporcao_aluno_nivel_1 string, 
  proporcao_aluno_nivel_2 string, 
  proporcao_aluno_nivel_3 string, 
  proporcao_aluno_nivel_4 string, 
  proporcao_aluno_nivel_5 string, 
  proporcao_aluno_nivel_6 string, 
  proporcao_aluno_nivel_7 string, 
  proporcao_aluno_nivel_8 string, 
  data_ingestao timestamp
  )
LOCATION
  's3://<BUCKET_S3>/bronze/municipio/'
TBLPROPERTIES (
  'format' = 'parquet',
  'write_compression' = 'snappy'
);

CREATE EXTERNAL TABLE IF NOT EXISTS db_bronze_alfabetizacao.uf(
  ano bigint, 
  sigla_uf string, 
  serie bigint, 
  rede bigint, 
  taxa_alfabetizacao double, 
  media_portugues double, 
  proporcao_aluno_nivel_0 double, 
  proporcao_aluno_nivel_1 double, 
  proporcao_aluno_nivel_2 double, 
  proporcao_aluno_nivel_3 double, 
  proporcao_aluno_nivel_4 double, 
  proporcao_aluno_nivel_5 double, 
  proporcao_aluno_nivel_6 double, 
  proporcao_aluno_nivel_7 double, 
  proporcao_aluno_nivel_8 double, 
  data_ingestao timestamp
  )
LOCATION
  's3://<BUCKET_S3>/bronze/uf/'
TBLPROPERTIES (
  'format' = 'parquet',
  'write_compression' = 'snappy'
);