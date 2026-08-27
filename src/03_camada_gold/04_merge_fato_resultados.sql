MERGE INTO db_gold_alfabetizacao.fct_resultado_alfabetizacao AS target
USING (
    WITH result_municipio AS (
        SELECT
            CAST(result.ano AS integer) AS ano,
            concat('MUN:', trim(CAST(result.id_municipio AS varchar))) AS geo_key,
            trim(CAST(result.serie AS varchar)) AS serie_key,
            CASE trim(CAST(result.rede AS varchar))
                WHEN '0' THEN 'TOTAL'
                WHEN '1' THEN 'FEDERAL'
                WHEN '2' THEN 'ESTADUAL'
                WHEN '3' THEN 'MUNICIPAL'
                WHEN '4' THEN 'PRIVADA'
                WHEN '5' THEN 'PUBLICA_EST_MUN'
                WHEN '6' THEN 'PUBLICA'
            END AS rede_key,
            CAST(result.taxa_alfabetizacao AS double) AS taxa_alfabetizacao_pct,
            CAST(result.media_portugues AS double) AS media_portugues,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_0 AS double) END AS nivel_0_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_1 AS double) END AS nivel_1_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_2 AS double) END AS nivel_2_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_3 AS double) END AS nivel_3_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_4 AS double) END AS nivel_4_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_5 AS double) END AS nivel_5_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_6 AS double) END AS nivel_6_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_7 AS double) END AS nivel_7_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_8 AS double) END AS nivel_8_pct,
            CASE WHEN trim(CAST(result.rede AS varchar)) = '3' THEN CAST(meta.percentual_participacao AS double) END AS percentual_participacao_pct,
            CAST(result.ano AS integer) <> 2023 AS distribuicao_niveis_disponivel,
            CASE WHEN trim(CAST(result.rede AS varchar)) = '3' THEN CAST(meta.taxa_alfabetizacao AS double) END AS taxa_alfabetizacao_alternativa_pct,
            CASE
                WHEN trim(CAST(result.rede AS varchar)) = '3' AND meta.taxa_alfabetizacao IS NOT NULL
                THEN CAST(result.taxa_alfabetizacao AS double) - CAST(meta.taxa_alfabetizacao AS double)
            END AS delta_taxa_fontes_pp,
            'silver.municipio' AS fonte_taxa,
            false AS flag_fallback_taxa,
            try_cast(result.data_processamento_silver AS timestamp) AS data_processamento_silver,
            CAST(current_timestamp AS timestamp) AS atualizado_em
        FROM db_silver_alfabetizacao.municipio result
        LEFT JOIN db_silver_alfabetizacao.meta_alfabetizacao_municipio meta
            ON CAST(result.id_municipio AS varchar) = CAST(meta.id_municipio AS varchar)
           AND CAST(result.ano AS integer) = CAST(meta.ano AS integer)
           AND trim(CAST(result.rede AS varchar)) = '3'
    ),
    result_uf AS (
        SELECT
            CAST(result.ano AS integer) AS ano,
            concat('UF:', upper(trim(CAST(result.sigla_uf AS varchar)))) AS geo_key,
            trim(CAST(result.serie AS varchar)) AS serie_key,
            CASE trim(CAST(result.rede AS varchar))
                WHEN '0' THEN 'TOTAL'
                WHEN '1' THEN 'FEDERAL'
                WHEN '2' THEN 'ESTADUAL'
                WHEN '3' THEN 'MUNICIPAL'
                WHEN '4' THEN 'PRIVADA'
                WHEN '5' THEN 'PUBLICA_EST_MUN'
                WHEN '6' THEN 'PUBLICA'
            END AS rede_key,
            CAST(result.taxa_alfabetizacao AS double) AS taxa_alfabetizacao_pct,
            CAST(result.media_portugues AS double) AS media_portugues,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_0 AS double) END AS nivel_0_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_1 AS double) END AS nivel_1_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_2 AS double) END AS nivel_2_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_3 AS double) END AS nivel_3_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_4 AS double) END AS nivel_4_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_5 AS double) END AS nivel_5_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_6 AS double) END AS nivel_6_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_7 AS double) END AS nivel_7_pct,
            CASE WHEN CAST(result.ano AS integer) = 2023 THEN NULL ELSE CAST(result.proporcao_aluno_nivel_8 AS double) END AS nivel_8_pct,
            CASE WHEN trim(CAST(result.rede AS varchar)) = '5' THEN CAST(meta.percentual_participacao AS double) END AS percentual_participacao_pct,
            CAST(result.ano AS integer) <> 2023 AS distribuicao_niveis_disponivel,
            CASE WHEN trim(CAST(result.rede AS varchar)) = '5' THEN CAST(meta.taxa_alfabetizacao AS double) END AS taxa_alfabetizacao_alternativa_pct,
            CASE
                WHEN trim(CAST(result.rede AS varchar)) = '5' AND meta.taxa_alfabetizacao IS NOT NULL
                THEN CAST(result.taxa_alfabetizacao AS double) - CAST(meta.taxa_alfabetizacao AS double)
            END AS delta_taxa_fontes_pp,
            'silver.uf' AS fonte_taxa,
            false AS flag_fallback_taxa,
            try_cast(result.data_processamento_silver AS timestamp) AS data_processamento_silver,
            CAST(current_timestamp AS timestamp) AS atualizado_em
        FROM db_silver_alfabetizacao.uf result
        LEFT JOIN db_silver_alfabetizacao.meta_alfabetizacao_uf meta
            ON CAST(result.sigla_uf AS varchar) = CAST(meta.sigla_uf AS varchar)
           AND CAST(result.ano AS integer) = CAST(meta.ano AS integer)
           AND trim(CAST(result.rede AS varchar)) = '5'
    ),
    missing_municipio AS (
        SELECT
            CAST(meta.ano AS integer) AS ano,
            concat('MUN:', trim(CAST(meta.id_municipio AS varchar))) AS geo_key,
            '2' AS serie_key,
            'MUNICIPAL' AS rede_key,
            CAST(meta.taxa_alfabetizacao AS double) AS taxa_alfabetizacao_pct,
            CAST(NULL AS double) AS media_portugues,
            CAST(NULL AS double) AS nivel_0_pct,
            CAST(NULL AS double) AS nivel_1_pct,
            CAST(NULL AS double) AS nivel_2_pct,
            CAST(NULL AS double) AS nivel_3_pct,
            CAST(NULL AS double) AS nivel_4_pct,
            CAST(NULL AS double) AS nivel_5_pct,
            CAST(NULL AS double) AS nivel_6_pct,
            CAST(NULL AS double) AS nivel_7_pct,
            CAST(NULL AS double) AS nivel_8_pct,
            CAST(meta.percentual_participacao AS double) AS percentual_participacao_pct,
            false AS distribuicao_niveis_disponivel,
            CAST(NULL AS double) AS taxa_alfabetizacao_alternativa_pct,
            CAST(NULL AS double) AS delta_taxa_fontes_pp,
            'silver.meta_alfabetizacao_municipio' AS fonte_taxa,
            true AS flag_fallback_taxa,
            try_cast(meta.data_processamento_silver AS timestamp) AS data_processamento_silver,
            CAST(current_timestamp AS timestamp) AS atualizado_em
        FROM db_silver_alfabetizacao.meta_alfabetizacao_municipio meta
        LEFT JOIN db_silver_alfabetizacao.municipio result
            ON CAST(meta.id_municipio AS varchar) = CAST(result.id_municipio AS varchar)
           AND CAST(meta.ano AS integer) = CAST(result.ano AS integer)
           AND trim(CAST(result.rede AS varchar)) = '3'
        WHERE result.id_municipio IS NULL
    ),
    missing_uf AS (
        SELECT
            CAST(meta.ano AS integer) AS ano,
            concat('UF:', upper(trim(CAST(meta.sigla_uf AS varchar)))) AS geo_key,
            '2' AS serie_key,
            'PUBLICA_EST_MUN' AS rede_key,
            CAST(meta.taxa_alfabetizacao AS double) AS taxa_alfabetizacao_pct,
            CAST(NULL AS double) AS media_portugues,
            CAST(NULL AS double) AS nivel_0_pct,
            CAST(NULL AS double) AS nivel_1_pct,
            CAST(NULL AS double) AS nivel_2_pct,
            CAST(NULL AS double) AS nivel_3_pct,
            CAST(NULL AS double) AS nivel_4_pct,
            CAST(NULL AS double) AS nivel_5_pct,
            CAST(NULL AS double) AS nivel_6_pct,
            CAST(NULL AS double) AS nivel_7_pct,
            CAST(NULL AS double) AS nivel_8_pct,
            CAST(meta.percentual_participacao AS double) AS percentual_participacao_pct,
            false AS distribuicao_niveis_disponivel,
            CAST(NULL AS double) AS taxa_alfabetizacao_alternativa_pct,
            CAST(NULL AS double) AS delta_taxa_fontes_pp,
            'silver.meta_alfabetizacao_uf' AS fonte_taxa,
            true AS flag_fallback_taxa,
            try_cast(meta.data_processamento_silver AS timestamp) AS data_processamento_silver,
            CAST(current_timestamp AS timestamp) AS atualizado_em
        FROM db_silver_alfabetizacao.meta_alfabetizacao_uf meta
        LEFT JOIN db_silver_alfabetizacao.uf result
            ON CAST(meta.sigla_uf AS varchar) = CAST(result.sigla_uf AS varchar)
           AND CAST(meta.ano AS integer) = CAST(result.ano AS integer)
           AND trim(CAST(result.rede AS varchar)) = '5'
        WHERE result.sigla_uf IS NULL
          AND (
              meta.taxa_alfabetizacao IS NOT NULL
              OR meta.percentual_participacao IS NOT NULL
          )
    ),
    result_brasil AS (
        SELECT
            CAST(ano AS integer) AS ano,
            'BR' AS geo_key,
            '2' AS serie_key,
            'PUBLICA' AS rede_key,
            CAST(taxa_alfabetizacao AS double) AS taxa_alfabetizacao_pct,
            CAST(NULL AS double) AS media_portugues,
            CAST(NULL AS double) AS nivel_0_pct,
            CAST(NULL AS double) AS nivel_1_pct,
            CAST(NULL AS double) AS nivel_2_pct,
            CAST(NULL AS double) AS nivel_3_pct,
            CAST(NULL AS double) AS nivel_4_pct,
            CAST(NULL AS double) AS nivel_5_pct,
            CAST(NULL AS double) AS nivel_6_pct,
            CAST(NULL AS double) AS nivel_7_pct,
            CAST(NULL AS double) AS nivel_8_pct,
            CAST(percentual_participacao AS double) AS percentual_participacao_pct,
            false AS distribuicao_niveis_disponivel,
            CAST(NULL AS double) AS taxa_alfabetizacao_alternativa_pct,
            CAST(NULL AS double) AS delta_taxa_fontes_pp,
            'silver.meta_alfabetizacao_brasil' AS fonte_taxa,
            true AS flag_fallback_taxa,
            try_cast(data_processamento_silver AS timestamp) AS data_processamento_silver,
            CAST(current_timestamp AS timestamp) AS atualizado_em
        FROM db_silver_alfabetizacao.meta_alfabetizacao_brasil
    )
    SELECT * FROM result_municipio
    UNION ALL SELECT * FROM result_uf
    UNION ALL SELECT * FROM missing_municipio
    UNION ALL SELECT * FROM missing_uf
    UNION ALL SELECT * FROM result_brasil
) AS source
ON target.ano = source.ano
AND target.geo_key = source.geo_key
AND target.serie_key = source.serie_key
AND target.rede_key = source.rede_key
WHEN MATCHED THEN UPDATE SET
    taxa_alfabetizacao_pct = source.taxa_alfabetizacao_pct,
    media_portugues = source.media_portugues,
    nivel_0_pct = source.nivel_0_pct,
    nivel_1_pct = source.nivel_1_pct,
    nivel_2_pct = source.nivel_2_pct,
    nivel_3_pct = source.nivel_3_pct,
    nivel_4_pct = source.nivel_4_pct,
    nivel_5_pct = source.nivel_5_pct,
    nivel_6_pct = source.nivel_6_pct,
    nivel_7_pct = source.nivel_7_pct,
    nivel_8_pct = source.nivel_8_pct,
    percentual_participacao_pct = source.percentual_participacao_pct,
    distribuicao_niveis_disponivel = source.distribuicao_niveis_disponivel,
    taxa_alfabetizacao_alternativa_pct = source.taxa_alfabetizacao_alternativa_pct,
    delta_taxa_fontes_pp = source.delta_taxa_fontes_pp,
    fonte_taxa = source.fonte_taxa,
    flag_fallback_taxa = source.flag_fallback_taxa,
    data_processamento_silver = source.data_processamento_silver,
    atualizado_em = source.atualizado_em
WHEN NOT MATCHED THEN INSERT (
    ano, geo_key, serie_key, rede_key, taxa_alfabetizacao_pct,
    media_portugues, nivel_0_pct, nivel_1_pct, nivel_2_pct, nivel_3_pct,
    nivel_4_pct, nivel_5_pct, nivel_6_pct, nivel_7_pct, nivel_8_pct,
    percentual_participacao_pct, distribuicao_niveis_disponivel,
    taxa_alfabetizacao_alternativa_pct, delta_taxa_fontes_pp, fonte_taxa,
    flag_fallback_taxa, data_processamento_silver, atualizado_em
) VALUES (
    source.ano, source.geo_key, source.serie_key, source.rede_key,
    source.taxa_alfabetizacao_pct, source.media_portugues, source.nivel_0_pct,
    source.nivel_1_pct, source.nivel_2_pct, source.nivel_3_pct,
    source.nivel_4_pct, source.nivel_5_pct, source.nivel_6_pct,
    source.nivel_7_pct, source.nivel_8_pct,
    source.percentual_participacao_pct,
    source.distribuicao_niveis_disponivel,
    source.taxa_alfabetizacao_alternativa_pct, source.delta_taxa_fontes_pp,
    source.fonte_taxa, source.flag_fallback_taxa,
    source.data_processamento_silver, source.atualizado_em
);