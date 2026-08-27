MERGE INTO db_gold_alfabetizacao.dim_serie AS target
USING (
    SELECT
        '2' AS serie_key,
        '2° ano do Ensino Fundamental' AS nome_serie,
        2 AS ordem
) AS source
ON target.serie_key = source.serie_key
WHEN MATCHED THEN UPDATE SET
    nome_serie = source.nome_serie,
    ordem = source.ordem,
    atualizado_em = CAST(current_timestamp AS timestamp)
WHEN NOT MATCHED THEN INSERT (
    serie_key, nome_serie, ordem, atualizado_em
) VALUES (
    source.serie_key, source.nome_serie, source.ordem,
    CAST(current_timestamp AS timestamp)
);