MERGE INTO db_gold_alfabetizacao.fct_cobertura_avaliacao AS target
USING (
    SELECT
        CAST(ano AS integer) AS ano,
        concat('MUN:', trim(CAST(id_municipio AS varchar))) AS geo_key,
        trim(CAST(serie AS varchar)) AS serie_key,
        CASE trim(CAST(rede AS varchar))
            WHEN '0' THEN 'TOTAL'
            WHEN '1' THEN 'FEDERAL'
            WHEN '2' THEN 'ESTADUAL'
            WHEN '3' THEN 'MUNICIPAL'
            WHEN '4' THEN 'PRIVADA'
            WHEN '5' THEN 'PUBLICA_EST_MUN'
            WHEN '6' THEN 'PUBLICA'
        END AS rede_key,
        
        -- Agregações
        COUNT(id_aluno) AS quantidade_registros,
        SUM(CASE WHEN desc_presenca = 'Presente' THEN 1 ELSE 0 END) AS quantidade_presentes,
        SUM(CASE WHEN desc_preenchimento = 'Prova preenchida' THEN 1 ELSE 0 END) AS quantidade_cadernos_validos,
        SUM(CAST(peso_aluno AS double)) AS soma_peso_aluno,
        
        -- Cálculos de Porcentagem e Ponderação
        (CAST(SUM(CASE WHEN desc_presenca = 'Presente' THEN 1 ELSE 0 END) AS double) / COUNT(id_aluno)) * 100 AS taxa_presenca_pct,
        
        (SUM(CASE WHEN desc_alfabetizado = 'Sim' THEN CAST(peso_aluno AS double) ELSE 0 END) / 
         NULLIF(SUM(CASE WHEN desc_preenchimento = 'Prova preenchida' THEN CAST(peso_aluno AS double) ELSE 0 END), 0)) * 100 AS taxa_alfabetizacao_ponderada_pct,
         
        SUM(CAST(proficiencia AS double) * CAST(peso_aluno AS double)) / 
        NULLIF(SUM(CASE WHEN proficiencia IS NOT NULL THEN CAST(peso_aluno AS double) ELSE 0 END), 0) AS media_proficiencia_ponderada,
        
        CAST(current_timestamp AS timestamp) AS atualizado_em
    FROM db_silver_alfabetizacao.alunos
    GROUP BY
        CAST(ano AS integer),
        concat('MUN:', trim(CAST(id_municipio AS varchar))),
        trim(CAST(serie AS varchar)),
        CASE trim(CAST(rede AS varchar))
            WHEN '0' THEN 'TOTAL'
            WHEN '1' THEN 'FEDERAL'
            WHEN '2' THEN 'ESTADUAL'
            WHEN '3' THEN 'MUNICIPAL'
            WHEN '4' THEN 'PRIVADA'
            WHEN '5' THEN 'PUBLICA_EST_MUN'
            WHEN '6' THEN 'PUBLICA'
        END
) AS source
ON target.ano = source.ano
AND target.geo_key = source.geo_key
AND target.serie_key = source.serie_key
AND target.rede_key = source.rede_key
WHEN MATCHED THEN UPDATE SET
    quantidade_registros = source.quantidade_registros,
    quantidade_presentes = source.quantidade_presentes,
    quantidade_cadernos_validos = source.quantidade_cadernos_validos,
    soma_peso_aluno = source.soma_peso_aluno,
    taxa_presenca_pct = source.taxa_presenca_pct,
    taxa_alfabetizacao_ponderada_pct = source.taxa_alfabetizacao_ponderada_pct,
    media_proficiencia_ponderada = source.media_proficiencia_ponderada,
    atualizado_em = source.atualizado_em
WHEN NOT MATCHED THEN INSERT (
    ano, geo_key, serie_key, rede_key, quantidade_registros,
    quantidade_presentes, quantidade_cadernos_validos, soma_peso_aluno,
    taxa_presenca_pct, taxa_alfabetizacao_ponderada_pct, media_proficiencia_ponderada,
    atualizado_em
) VALUES (
    source.ano, source.geo_key, source.serie_key, source.rede_key,
    source.quantidade_registros, source.quantidade_presentes,
    source.quantidade_cadernos_validos, source.soma_peso_aluno,
    source.taxa_presenca_pct, source.taxa_alfabetizacao_ponderada_pct,
    source.media_proficiencia_ponderada, source.atualizado_em
);