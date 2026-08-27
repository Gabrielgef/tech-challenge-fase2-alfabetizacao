CREATE OR REPLACE VIEW db_silver_alfabetizacao.vw_quality_gate_silver AS
WITH checks AS (
    SELECT
        'municipio_chave_duplicada' AS teste,
        'BLOCKER' AS severidade,
        count(*) AS violacoes
    FROM (
        SELECT id_municipio, serie, rede, ano
        FROM db_silver_alfabetizacao.municipio
        GROUP BY 1, 2, 3, 4
        HAVING count(*) > 1
    ) duplicated_municipio

    UNION ALL

    SELECT
        'uf_chave_duplicada',
        'BLOCKER',
        count(*)
    FROM (
        SELECT sigla_uf, serie, rede, ano
        FROM db_silver_alfabetizacao.uf
        GROUP BY 1, 2, 3, 4
        HAVING count(*) > 1
    ) duplicated_uf

    UNION ALL

    SELECT
        'meta_municipio_chave_duplicada',
        'BLOCKER',
        count(*)
    FROM (
        SELECT id_municipio, rede, ano
        FROM db_silver_alfabetizacao.meta_alfabetizacao_municipio
        GROUP BY 1, 2, 3
        HAVING count(*) > 1
    ) duplicated_meta_municipio

    UNION ALL

    SELECT
        'meta_uf_chave_duplicada',
        'BLOCKER',
        count(*)
    FROM (
        SELECT sigla_uf, rede, ano
        FROM db_silver_alfabetizacao.meta_alfabetizacao_uf
        GROUP BY 1, 2, 3
        HAVING count(*) > 1
    ) duplicated_meta_uf

    UNION ALL

    SELECT
        'municipio_orfao',
        'BLOCKER',
        count(*)
    FROM db_silver_alfabetizacao.municipio fact
    LEFT JOIN db_silver_alfabetizacao.dim_municipio dim
        ON fact.id_municipio = dim.id_municipio
    WHERE dim.id_municipio IS NULL

    UNION ALL

    SELECT
        'uf_orfa',
        'BLOCKER',
        count(*)
    FROM db_silver_alfabetizacao.uf fact
    LEFT JOIN db_silver_alfabetizacao.dim_uf dim
        ON fact.sigla_uf = dim.sigla
    WHERE dim.sigla IS NULL

    UNION ALL

    SELECT
        'percentuais_fora_da_faixa',
        'BLOCKER',
        count(*)
    FROM db_silver_alfabetizacao.municipio
    WHERE taxa_alfabetizacao NOT BETWEEN 0 AND 100
       OR media_portugues NOT BETWEEN 0 AND 1000
       OR proporcao_aluno_nivel_0 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_1 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_2 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_3 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_4 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_5 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_6 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_7 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_8 NOT BETWEEN 0 AND 100

    UNION ALL

    SELECT
        'percentuais_uf_fora_da_faixa',
        'BLOCKER',
        count(*)
    FROM db_silver_alfabetizacao.uf
    WHERE taxa_alfabetizacao NOT BETWEEN 0 AND 100
       OR media_portugues NOT BETWEEN 0 AND 1000
       OR proporcao_aluno_nivel_0 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_1 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_2 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_3 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_4 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_5 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_6 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_7 NOT BETWEEN 0 AND 100
       OR proporcao_aluno_nivel_8 NOT BETWEEN 0 AND 100

    UNION ALL

    SELECT
        'percentuais_metas_fora_da_faixa',
        'BLOCKER',
        count(*)
    FROM (
        SELECT
            taxa_alfabetizacao,
            meta_alfabetizacao_2024,
            meta_alfabetizacao_2025,
            meta_alfabetizacao_2026,
            meta_alfabetizacao_2027,
            meta_alfabetizacao_2028,
            meta_alfabetizacao_2029,
            meta_alfabetizacao_2030,
            percentual_participacao
        FROM db_silver_alfabetizacao.meta_alfabetizacao_municipio

        UNION ALL

        SELECT
            taxa_alfabetizacao,
            meta_alfabetizacao_2024,
            meta_alfabetizacao_2025,
            meta_alfabetizacao_2026,
            meta_alfabetizacao_2027,
            meta_alfabetizacao_2028,
            meta_alfabetizacao_2029,
            meta_alfabetizacao_2030,
            percentual_participacao
        FROM db_silver_alfabetizacao.meta_alfabetizacao_uf

        UNION ALL

        SELECT
            taxa_alfabetizacao,
            meta_alfabetizacao_2024,
            meta_alfabetizacao_2025,
            meta_alfabetizacao_2026,
            meta_alfabetizacao_2027,
            meta_alfabetizacao_2028,
            meta_alfabetizacao_2029,
            meta_alfabetizacao_2030,
            percentual_participacao
        FROM db_silver_alfabetizacao.meta_alfabetizacao_brasil
    ) target_values
    WHERE taxa_alfabetizacao NOT BETWEEN 0 AND 100
       OR meta_alfabetizacao_2024 NOT BETWEEN 0 AND 100
       OR meta_alfabetizacao_2025 NOT BETWEEN 0 AND 100
       OR meta_alfabetizacao_2026 NOT BETWEEN 0 AND 100
       OR meta_alfabetizacao_2027 NOT BETWEEN 0 AND 100
       OR meta_alfabetizacao_2028 NOT BETWEEN 0 AND 100
       OR meta_alfabetizacao_2029 NOT BETWEEN 0 AND 100
       OR meta_alfabetizacao_2030 NOT BETWEEN 0 AND 100
       OR percentual_participacao NOT BETWEEN 0 AND 100

    UNION ALL

    SELECT
        'soma_niveis_2024_invalida',
        'BLOCKER',
        count(*)
    FROM (
        SELECT
            proporcao_aluno_nivel_0 + proporcao_aluno_nivel_1
            + proporcao_aluno_nivel_2 + proporcao_aluno_nivel_3
            + proporcao_aluno_nivel_4 + proporcao_aluno_nivel_5
            + proporcao_aluno_nivel_6 + proporcao_aluno_nivel_7
            + proporcao_aluno_nivel_8 AS soma_niveis
        FROM db_silver_alfabetizacao.municipio
        WHERE ano = '2024'

        UNION ALL

        SELECT
            proporcao_aluno_nivel_0 + proporcao_aluno_nivel_1
            + proporcao_aluno_nivel_2 + proporcao_aluno_nivel_3
            + proporcao_aluno_nivel_4 + proporcao_aluno_nivel_5
            + proporcao_aluno_nivel_6 + proporcao_aluno_nivel_7
            + proporcao_aluno_nivel_8
        FROM db_silver_alfabetizacao.uf
        WHERE ano = '2024'
    ) level_sums
    WHERE abs(soma_niveis - 100.0) > 0.1

    UNION ALL

    SELECT
        'niveis_2023_tratados_como_indisponiveis',
        'INFO',
        count(*)
    FROM (
        SELECT ano FROM db_silver_alfabetizacao.municipio WHERE ano = '2023'
        UNION ALL
        SELECT ano FROM db_silver_alfabetizacao.uf WHERE ano = '2023'
    ) unavailable_2023

    UNION ALL

    SELECT
        'divergencia_taxa_municipio_acima_0_1pp',
        'WARN',
        count(*)
    FROM db_silver_alfabetizacao.municipio result
    JOIN db_silver_alfabetizacao.meta_alfabetizacao_municipio target
        ON result.id_municipio = target.id_municipio
       AND result.ano = target.ano
       AND result.rede = 3
    WHERE abs(result.taxa_alfabetizacao - target.taxa_alfabetizacao) > 0.1
)
SELECT teste, severidade, violacoes
FROM checks
;