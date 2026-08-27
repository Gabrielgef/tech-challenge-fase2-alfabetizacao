
CREATE OR REPLACE VIEW db_gold_alfabetizacao.vw_quality_gate_gold AS
WITH checks AS (
    SELECT
        'resultado_chave_duplicada' AS teste,
        'BLOCKER' AS severidade,
        count(*) AS violacoes
    FROM (
        SELECT ano, geo_key, serie_key, rede_key
        FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao
        GROUP BY 1, 2, 3, 4
        HAVING count(*) > 1
    ) duplicated_results

    UNION ALL

    SELECT
        'meta_chave_duplicada',
        'BLOCKER',
        count(*)
    FROM (
        SELECT ano_referencia, ano_meta, geo_key, rede_key
        FROM db_gold_alfabetizacao.fct_meta_alfabetizacao
        GROUP BY 1, 2, 3, 4
        HAVING count(*) > 1
    ) duplicated_targets

    UNION ALL

    SELECT
        'resultado_geografia_orfa',
        'BLOCKER',
        count(*)
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao fact
    LEFT JOIN db_gold_alfabetizacao.dim_geografia dim
        ON fact.geo_key = dim.geo_key
    WHERE dim.geo_key IS NULL

    UNION ALL

    SELECT
        'resultado_rede_orfa',
        'BLOCKER',
        count(*)
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao fact
    LEFT JOIN db_gold_alfabetizacao.dim_rede dim
        ON fact.rede_key = dim.rede_key
    WHERE dim.rede_key IS NULL

    UNION ALL

    SELECT
        'resultado_serie_orfa',
        'BLOCKER',
        count(*)
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao fact
    LEFT JOIN db_gold_alfabetizacao.dim_serie dim
        ON fact.serie_key = dim.serie_key
    WHERE dim.serie_key IS NULL

    UNION ALL

    SELECT
        'resultado_percentual_fora_faixa',
        'BLOCKER',
        count(*)
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao
    WHERE taxa_alfabetizacao_pct NOT BETWEEN 0 AND 100
       OR percentual_participacao_pct NOT BETWEEN 0 AND 100
       OR taxa_alfabetizacao_alternativa_pct NOT BETWEEN 0 AND 100

    UNION ALL

    SELECT
        'niveis_fora_da_faixa',
        'BLOCKER',
        count(*)
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao
    WHERE nivel_0_pct NOT BETWEEN 0 AND 100
       OR nivel_1_pct NOT BETWEEN 0 AND 100
       OR nivel_2_pct NOT BETWEEN 0 AND 100
       OR nivel_3_pct NOT BETWEEN 0 AND 100
       OR nivel_4_pct NOT BETWEEN 0 AND 100
       OR nivel_5_pct NOT BETWEEN 0 AND 100
       OR nivel_6_pct NOT BETWEEN 0 AND 100
       OR nivel_7_pct NOT BETWEEN 0 AND 100
       OR nivel_8_pct NOT BETWEEN 0 AND 100

    UNION ALL

    SELECT
        'meta_fora_faixa_ou_ano',
        'BLOCKER',
        count(*)
    FROM db_gold_alfabetizacao.fct_meta_alfabetizacao
    WHERE ano_meta NOT BETWEEN 2024 AND 2030
       OR (meta_disponivel AND valor_meta_pct NOT BETWEEN 0 AND 100)
       OR (NOT meta_disponivel AND valor_meta_pct IS NOT NULL)

    UNION ALL

    SELECT
        'niveis_disponiveis_invalidos',
        'BLOCKER',
        count(*)
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao
    WHERE distribuicao_niveis_disponivel IS NULL
       OR (
          distribuicao_niveis_disponivel
      AND (
          nivel_0_pct IS NULL OR nivel_1_pct IS NULL OR nivel_2_pct IS NULL
          OR nivel_3_pct IS NULL OR nivel_4_pct IS NULL OR nivel_5_pct IS NULL
          OR nivel_6_pct IS NULL OR nivel_7_pct IS NULL OR nivel_8_pct IS NULL
          OR abs(
              nivel_0_pct + nivel_1_pct + nivel_2_pct + nivel_3_pct
              + nivel_4_pct + nivel_5_pct + nivel_6_pct + nivel_7_pct
              + nivel_8_pct - 100.0
          ) > 0.1
      )
      )

    UNION ALL

    SELECT
        'niveis_indisponiveis_nao_nulos',
        'BLOCKER',
        count(*)
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao
    WHERE NOT distribuicao_niveis_disponivel
      AND coalesce(
          nivel_0_pct, nivel_1_pct, nivel_2_pct, nivel_3_pct, nivel_4_pct,
          nivel_5_pct, nivel_6_pct, nivel_7_pct, nivel_8_pct
      ) IS NOT NULL

    UNION ALL

    SELECT
        'divergencia_taxa_acima_0_1pp',
        'WARN',
        count(*)
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao
    WHERE abs(delta_taxa_fontes_pp) > 0.1

    UNION ALL

    SELECT
        'taxa_com_fallback',
        'INFO',
        count(*)
    FROM db_gold_alfabetizacao.fct_resultado_alfabetizacao
    WHERE flag_fallback_taxa
)
SELECT teste, severidade, violacoes
FROM checks;