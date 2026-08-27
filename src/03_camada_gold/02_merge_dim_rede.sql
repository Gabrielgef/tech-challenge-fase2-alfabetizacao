MERGE INTO db_gold_alfabetizacao.dim_rede AS target
USING (
    SELECT *
    FROM (
        VALUES
            ('TOTAL', '0', 'Total (todas as redes; confirmar rótulo na origem)', false, false),
            ('FEDERAL', '1', 'Federal', true, true),
            ('ESTADUAL', '2', 'Estadual', true, true),
            ('MUNICIPAL', '3', 'Municipal', true, true),
            ('PRIVADA', '4', 'Privada', false, true),
            ('PUBLICA_EST_MUN', '5', 'Pública (Estadual e Municipal)', true, true),
            ('PUBLICA', '6', 'Pública (escopo completo; confirmar rótulo na origem)', true, false)
    ) AS network(rede_key, codigo_rede_origem, nome_rede, escopo_publico, rotulo_confirmado)
) AS source
ON target.rede_key = source.rede_key
WHEN MATCHED THEN UPDATE SET
    codigo_rede_origem = source.codigo_rede_origem,
    nome_rede = source.nome_rede,
    escopo_publico = source.escopo_publico,
    rotulo_confirmado = source.rotulo_confirmado,
    atualizado_em = CAST(current_timestamp AS timestamp)
WHEN NOT MATCHED THEN INSERT (
    rede_key, codigo_rede_origem, nome_rede, escopo_publico,
    rotulo_confirmado, atualizado_em
) VALUES (
    source.rede_key, source.codigo_rede_origem, source.nome_rede,
    source.escopo_publico, source.rotulo_confirmado,
    CAST(current_timestamp AS timestamp)
);