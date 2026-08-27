-- ==========================================
-- INSERT: Tabela dicionario
-- ==========================================
INSERT INTO db_bronze_alfabetizacao.dicionario
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.dicionario;
