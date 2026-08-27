-- Executar uma única vez no Athena Engine 3.
-- Views semânticas. Executar após todas as tabelas Fato (Resultados, Metas e Cobertura).

CREATE OR REPLACE VIEW db_gold_alfabetizacao.mart_resultado_meta AS
WITH meta_vigente AS (
    SELECT
        ano_referencia,
        ano_meta,
        geo_key,
        rede_key,
        valor_meta_pct,
        fonte_meta,
        row_number() OVER (
            PARTITION BY ano_meta, geo_key, rede_key
            ORDER BY ano_referencia DESC
        ) AS ordem_vigencia
    FROM db_gold_alfabetizacao.fct_meta_alfabetizacao
    WHERE meta_disponivel
      AND ano_referencia <= ano_meta
),
base AS (
    SELECT
        result.*,
        
        -- Integração Cobertura (Alunos)
        cob.quantidade_registros,
        cob.quantidade_presentes,
        cob.quantidade_cadernos_validos,
        cob.taxa_presenca_pct,
        cob.taxa_alfabetizacao_ponderada_pct,
        cob.media_proficiencia_ponderada,

        -- Integração Metas
        meta.ano_referencia AS ano_referencia_meta,
        meta.valor_meta_pct,
        meta.fonte_meta,
        
        lag(result.taxa_alfabetizacao_pct) OVER (
            PARTITION BY result.geo_key, result.serie_key, result.rede_key
            ORDER BY result.ano
        ) AS taxa_ano_anterior_pct
        
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao result
    LEFT JOIN meta_vigente meta
        ON result.ano = meta.ano_meta
       AND result.geo_key = meta.geo_key
       AND result.rede_key = meta.rede_key
       AND meta.ordem_vigencia = 1
    LEFT JOIN db_gold_alfabetizacao.fct_cobertura_avaliacao cob
        ON result.ano = cob.ano
       AND result.geo_key = cob.geo_key
       AND result.serie_key = cob.serie_key
       AND result.rede_key = cob.rede_key
)
SELECT
    base.*,
    taxa_alfabetizacao_pct - valor_meta_pct AS gap_meta_pp,
    CASE
        WHEN taxa_alfabetizacao_pct IS NULL OR valor_meta_pct IS NULL THEN NULL
        ELSE taxa_alfabetizacao_pct >= valor_meta_pct
    END AS atingiu_meta,
    taxa_alfabetizacao_pct - taxa_ano_anterior_pct AS variacao_ano_pp
FROM base;


CREATE OR REPLACE VIEW db_gold_alfabetizacao.mart_priorizacao_municipio AS
SELECT
    mart.*,
    CASE
        WHEN mart.valor_meta_pct IS NULL OR mart.variacao_ano_pp IS NULL THEN 'SEM_BASE'
        WHEN mart.gap_meta_pp < 0 AND mart.variacao_ano_pp < 0 THEN 'CRITICA'
        WHEN mart.gap_meta_pp < 0 AND mart.variacao_ano_pp >= 0 THEN 'RECUPERACAO'
        WHEN mart.gap_meta_pp >= 0 AND mart.variacao_ano_pp < 0 THEN 'SUSTENTACAO'
        ELSE 'REFERENCIA'
    END AS quadrante_prioridade,
    dense_rank() OVER (
        PARTITION BY mart.ano, mart.serie_key, mart.rede_key
        ORDER BY mart.gap_meta_pp ASC NULLS LAST,
                 mart.percentual_participacao_pct ASC NULLS LAST,
                 mart.taxa_alfabetizacao_pct ASC NULLS LAST
    ) AS ordem_prioridade
FROM db_gold_alfabetizacao.mart_resultado_meta mart
JOIN db_gold_alfabetizacao.dim_geografia geo
    ON mart.geo_key = geo.geo_key
WHERE geo.nivel_geografico = 'MUNICIPIO';


CREATE OR REPLACE VIEW db_gold_alfabetizacao.vw_ia_alfabetizacao AS
SELECT
    mart.ano,
    geo.nivel_geografico,
    mart.geo_key,
    geo.nome_geografia,
    geo.sigla_uf,
    mart.serie_key,
    serie.nome_serie,
    mart.rede_key,
    rede.nome_rede,
    
    -- Resultados Oficiais
    mart.taxa_alfabetizacao_pct,
    mart.media_portugues,
    mart.percentual_participacao_pct,
    
    -- Metas e Gaps
    mart.valor_meta_pct,
    mart.gap_meta_pp,
    mart.atingiu_meta,
    mart.variacao_ano_pp,
    
    CASE
        WHEN geo.nivel_geografico <> 'MUNICIPIO' THEN NULL
        WHEN mart.valor_meta_pct IS NULL OR mart.variacao_ano_pp IS NULL THEN 'SEM_BASE'
        WHEN mart.gap_meta_pp < 0 AND mart.variacao_ano_pp < 0 THEN 'CRITICA'
        WHEN mart.gap_meta_pp < 0 AND mart.variacao_ano_pp >= 0 THEN 'RECUPERACAO'
        WHEN mart.gap_meta_pp >= 0 AND mart.variacao_ano_pp < 0 THEN 'SUSTENTACAO'
        ELSE 'REFERENCIA'
    END AS quadrante_prioridade,
    
    -- Cobertura de Alunos (Novas Métricas)
    mart.quantidade_registros,
    mart.quantidade_presentes,
    mart.quantidade_cadernos_validos,
    mart.taxa_presenca_pct,
    mart.taxa_alfabetizacao_ponderada_pct,
    mart.media_proficiencia_ponderada,
    
    -- Distribuição de Níveis
    mart.nivel_0_pct,
    mart.nivel_1_pct,
    mart.nivel_2_pct,
    mart.nivel_3_pct,
    mart.nivel_4_pct,
    mart.nivel_5_pct,
    mart.nivel_6_pct,
    mart.nivel_7_pct,
    mart.nivel_8_pct,
    mart.distribuicao_niveis_disponivel,
    
    -- Rastreabilidade
    mart.fonte_taxa,
    mart.fonte_meta,
    mart.flag_fallback_taxa,
    mart.ano_referencia_meta,
    mart.atualizado_em
FROM db_gold_alfabetizacao.mart_resultado_meta mart
JOIN db_gold_alfabetizacao.dim_geografia geo
    ON mart.geo_key = geo.geo_key
JOIN db_gold_alfabetizacao.dim_serie serie
    ON mart.serie_key = serie.serie_key
JOIN db_gold_alfabetizacao.dim_rede rede
    ON mart.rede_key = rede.rede_key;