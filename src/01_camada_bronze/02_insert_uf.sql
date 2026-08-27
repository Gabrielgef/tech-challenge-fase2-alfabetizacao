-- ==========================================
-- INSERT: Tabela uf
-- ==========================================
INSERT INTO db_bronze_alfabetizacao.uf
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.uf;
