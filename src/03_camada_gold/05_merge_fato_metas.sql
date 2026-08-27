MERGE INTO db_gold_alfabetizacao.fct_meta_alfabetizacao AS target
USING (
    WITH meta_municipio AS (
        SELECT
            CAST(source.ano AS integer) AS ano_referencia,
            target_year.ano_meta,
            concat('MUN:', trim(source.id_municipio)) AS geo_key,
            'MUNICIPAL' AS rede_key,
            target_year.valor_meta_pct,
            target_year.valor_meta_pct IS NOT NULL AS meta_disponivel,
            'silver.meta_alfabetizacao_municipio' AS fonte_meta,
            try_cast(source.data_processamento_silver AS timestamp) AS data_processamento_silver,
            CAST(current_timestamp AS timestamp) AS atualizado_em
        FROM db_silver_alfabetizacao.meta_alfabetizacao_municipio source
        CROSS JOIN UNNEST(
            ARRAY[2024, 2025, 2026, 2027, 2028, 2029, 2030],
            ARRAY[
                CAST(source.meta_alfabetizacao_2024 AS double),
                CAST(source.meta_alfabetizacao_2025 AS double),
                CAST(source.meta_alfabetizacao_2026 AS double),
                CAST(source.meta_alfabetizacao_2027 AS double),
                CAST(source.meta_alfabetizacao_2028 AS double),
                CAST(source.meta_alfabetizacao_2029 AS double),
                CAST(source.meta_alfabetizacao_2030 AS double)
            ]
        ) AS target_year(ano_meta, valor_meta_pct)
    ),
    meta_uf AS (
        SELECT
            CAST(source.ano AS integer) AS ano_referencia,
            target_year.ano_meta,
            concat('UF:', upper(trim(source.sigla_uf))) AS geo_key,
            'PUBLICA_EST_MUN' AS rede_key,
            target_year.valor_meta_pct,
            target_year.valor_meta_pct IS NOT NULL AS meta_disponivel,
            'silver.meta_alfabetizacao_uf' AS fonte_meta,
            try_cast(source.data_processamento_silver AS timestamp) AS data_processamento_silver,
            CAST(current_timestamp AS timestamp) AS atualizado_em
        FROM db_silver_alfabetizacao.meta_alfabetizacao_uf source
        CROSS JOIN UNNEST(
            ARRAY[2024, 2025, 2026, 2027, 2028, 2029, 2030],
            ARRAY[
                CAST(source.meta_alfabetizacao_2024 AS double),
                CAST(source.meta_alfabetizacao_2025 AS double),
                CAST(source.meta_alfabetizacao_2026 AS double),
                CAST(source.meta_alfabetizacao_2027 AS double),
                CAST(source.meta_alfabetizacao_2028 AS double),
                CAST(source.meta_alfabetizacao_2029 AS double),
                CAST(source.meta_alfabetizacao_2030 AS double)
            ]
        ) AS target_year(ano_meta, valor_meta_pct)
    ),
    meta_brasil AS (
        SELECT
            CAST(source.ano AS integer) AS ano_referencia,
            target_year.ano_meta,
            'BR' AS geo_key,
            'PUBLICA' AS rede_key,
            target_year.valor_meta_pct,
            target_year.valor_meta_pct IS NOT NULL AS meta_disponivel,
            'silver.meta_alfabetizacao_brasil' AS fonte_meta,
            try_cast(source.data_processamento_silver AS timestamp) AS data_processamento_silver,
            CAST(current_timestamp AS timestamp) AS atualizado_em
        FROM db_silver_alfabetizacao.meta_alfabetizacao_brasil source
        CROSS JOIN UNNEST(
            ARRAY[2024, 2025, 2026, 2027, 2028, 2029, 2030],
            ARRAY[
                CAST(source.meta_alfabetizacao_2024 AS double),
                CAST(source.meta_alfabetizacao_2025 AS double),
                CAST(source.meta_alfabetizacao_2026 AS double),
                CAST(source.meta_alfabetizacao_2027 AS double),
                CAST(source.meta_alfabetizacao_2028 AS double),
                CAST(source.meta_alfabetizacao_2029 AS double),
                CAST(source.meta_alfabetizacao_2030 AS double)
            ]
        ) AS target_year(ano_meta, valor_meta_pct)
    )
    SELECT * FROM meta_municipio
    UNION ALL SELECT * FROM meta_uf
    UNION ALL SELECT * FROM meta_brasil
) AS source
ON target.ano_referencia = source.ano_referencia
AND target.ano_meta = source.ano_meta
AND target.geo_key = source.geo_key
AND target.rede_key = source.rede_key
WHEN MATCHED THEN UPDATE SET
    valor_meta_pct = source.valor_meta_pct,
    meta_disponivel = source.meta_disponivel,
    fonte_meta = source.fonte_meta,
    data_processamento_silver = source.data_processamento_silver,
    atualizado_em = source.atualizado_em
WHEN NOT MATCHED THEN INSERT (
    ano_referencia, ano_meta, geo_key, rede_key, valor_meta_pct,
    meta_disponivel, fonte_meta, data_processamento_silver,
    atualizado_em
) VALUES (
    source.ano_referencia, source.ano_meta, source.geo_key, source.rede_key,
    source.valor_meta_pct, source.meta_disponivel, source.fonte_meta,
    source.data_processamento_silver, source.atualizado_em
    );