-- Executar uma única vez no Athena Engine 3.
-- Substituir <BUCKET> pelo bucket real antes da implantação.

CREATE DATABASE IF NOT EXISTS db_gold_alfabetizacao;

CREATE TABLE IF NOT EXISTS db_gold_alfabetizacao.dim_geografia (
    geo_key string,
    nivel_geografico string,
    id_municipio string,
    sigla_uf string,
    nome_geografia string,
    parent_geo_key string,
    codigo_uf_ibge string,
    atualizado_em timestamp
)
LOCATION 's3://<BUCKET>/gold/dim_geografia/'
TBLPROPERTIES (
    'table_type' = 'ICEBERG',
    'format' = 'parquet',
    'write_compression' = 'snappy'
);

CREATE TABLE IF NOT EXISTS db_gold_alfabetizacao.dim_rede (
    rede_key string,
    codigo_rede_origem string,
    nome_rede string,
    escopo_publico boolean,
    rotulo_confirmado boolean,
    atualizado_em timestamp
)
LOCATION 's3://<BUCKET>/gold/dim_rede/'
TBLPROPERTIES (
    'table_type' = 'ICEBERG',
    'format' = 'parquet',
    'write_compression' = 'snappy'
);

CREATE TABLE IF NOT EXISTS db_gold_alfabetizacao.dim_serie (
    serie_key string,
    nome_serie string,
    ordem integer,
    atualizado_em timestamp
)
LOCATION 's3://<BUCKET>/gold/dim_serie/'
TBLPROPERTIES (
    'table_type' = 'ICEBERG',
    'format' = 'parquet',
    'write_compression' = 'snappy'
);

CREATE TABLE IF NOT EXISTS db_gold_alfabetizacao.fct_resultado_alfabetizacao (
    ano integer,
    geo_key string,
    serie_key string,
    rede_key string,
    taxa_alfabetizacao_pct double,
    media_portugues double,
    nivel_0_pct double,
    nivel_1_pct double,
    nivel_2_pct double,
    nivel_3_pct double,
    nivel_4_pct double,
    nivel_5_pct double,
    nivel_6_pct double,
    nivel_7_pct double,
    nivel_8_pct double,
    percentual_participacao_pct double,
    distribuicao_niveis_disponivel boolean,
    taxa_alfabetizacao_alternativa_pct double,
    delta_taxa_fontes_pp double,
    fonte_taxa string,
    flag_fallback_taxa boolean,
    data_processamento_silver timestamp,
    atualizado_em timestamp
)
LOCATION 's3://<BUCKET>/gold/fct_resultado_alfabetizacao/'
TBLPROPERTIES (
    'table_type' = 'ICEBERG',
    'format' = 'parquet',
    'write_compression' = 'snappy'
);

CREATE TABLE IF NOT EXISTS db_gold_alfabetizacao.fct_meta_alfabetizacao (
    ano_referencia integer,
    ano_meta integer,
    geo_key string,
    rede_key string,
    valor_meta_pct double,
    meta_disponivel boolean,
    fonte_meta string,
    data_processamento_silver timestamp,
    atualizado_em timestamp
)
LOCATION 's3://<BUCKET>/gold/fct_meta_alfabetizacao/'
TBLPROPERTIES (
    'table_type' = 'ICEBERG',
    'format' = 'parquet',
    'write_compression' = 'snappy'
);

-- Habilitar somente após recuperar e reconciliar a Silver de alunos.
CREATE TABLE IF NOT EXISTS db_gold_alfabetizacao.fct_cobertura_avaliacao (
    ano integer,
    geo_key string,
    serie_key string,
    rede_key string,
    quantidade_registros bigint,
    quantidade_presentes bigint,
    quantidade_cadernos_validos bigint,
    soma_peso_aluno double,
    taxa_presenca_pct double,
    taxa_alfabetizacao_ponderada_pct double,
    media_proficiencia_ponderada double,
    atualizado_em timestamp
)
PARTITIONED BY (ano)
LOCATION 's3://<BUCKET>/gold/fct_cobertura_avaliacao/'
TBLPROPERTIES (
    'table_type' = 'ICEBERG',
    'format' = 'parquet',
    'write_compression' = 'snappy'
);
