-- ==========================================
-- INSERT: Tabela meta_alfabetizacao_uf
-- ==========================================
INSERT INTO db_bronze_alfabetizacao.meta_alfabetizacao_uf
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.meta_alfabetizacao_uf;
