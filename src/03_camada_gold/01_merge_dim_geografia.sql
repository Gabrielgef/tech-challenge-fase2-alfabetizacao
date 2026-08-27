-- Substituir <RUN_ID> por um identificador imutável do lote.

MERGE INTO db_gold_alfabetizacao.dim_geografia AS target
USING (
    WITH uf_codigo AS (
        SELECT *
        FROM (
            VALUES
                ('11', 'RO'), ('12', 'AC'), ('13', 'AM'), ('14', 'RR'),
                ('15', 'PA'), ('16', 'AP'), ('17', 'TO'), ('21', 'MA'),
                ('22', 'PI'), ('23', 'CE'), ('24', 'RN'), ('25', 'PB'),
                ('26', 'PE'), ('27', 'AL'), ('28', 'SE'), ('29', 'BA'),
                ('31', 'MG'), ('32', 'ES'), ('33', 'RJ'), ('35', 'SP'),
                ('41', 'PR'), ('42', 'SC'), ('43', 'RS'), ('50', 'MS'),
                ('51', 'MT'), ('52', 'GO'), ('53', 'DF')
        ) AS map(codigo_uf_ibge, sigla_uf)
    )
    SELECT
        'BR' AS geo_key,
        'BRASIL' AS nivel_geografico,
        CAST(NULL AS varchar) AS id_municipio,
        CAST(NULL AS varchar) AS sigla_uf,
        'Brasil' AS nome_geografia,
        CAST(NULL AS varchar) AS parent_geo_key,
        CAST(NULL AS varchar) AS codigo_uf_ibge,
        '<RUN_ID>' AS run_id,
        CAST(current_timestamp AS timestamp) AS atualizado_em

    UNION ALL

    SELECT
        concat('UF:', upper(trim(uf.sigla))),
        'UF',
        CAST(NULL AS varchar),
        upper(trim(uf.sigla)),
        trim(uf.nome),
        'BR',
        map.codigo_uf_ibge,
        '<RUN_ID>',
        CAST(current_timestamp AS timestamp)
    FROM db_silver_alfabetizacao.dim_uf uf
    LEFT JOIN uf_codigo map ON upper(trim(uf.sigla)) = map.sigla_uf

    UNION ALL

    SELECT
        concat('MUN:', trim(municipio.id_municipio)),
        'MUNICIPIO',
        trim(municipio.id_municipio),
        map.sigla_uf,
        trim(municipio.nome),
        concat('UF:', map.sigla_uf),
        substr(trim(municipio.id_municipio), 1, 2),
        '<RUN_ID>',
        CAST(current_timestamp AS timestamp)
    FROM db_silver_alfabetizacao.dim_municipio municipio
    LEFT JOIN uf_codigo map
        ON substr(trim(municipio.id_municipio), 1, 2) = map.codigo_uf_ibge
) AS source
ON target.geo_key = source.geo_key
WHEN MATCHED THEN UPDATE SET
    nivel_geografico = source.nivel_geografico,
    id_municipio = source.id_municipio,
    sigla_uf = source.sigla_uf,
    nome_geografia = source.nome_geografia,
    parent_geo_key = source.parent_geo_key,
    codigo_uf_ibge = source.codigo_uf_ibge,
    atualizado_em = source.atualizado_em
WHEN NOT MATCHED THEN INSERT (
    geo_key, nivel_geografico, id_municipio, sigla_uf, nome_geografia,
    parent_geo_key, codigo_uf_ibge, atualizado_em
) VALUES (
    source.geo_key, source.nivel_geografico, source.id_municipio,
    source.sigla_uf, source.nome_geografia, source.parent_geo_key,
    source.codigo_uf_ibge, source.atualizado_em
);

