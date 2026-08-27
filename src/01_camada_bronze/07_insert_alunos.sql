-- ==========================================
-- INSERT: Tabela alunos
-- ==========================================
INSERT INTO db_bronze_alfabetizacao.alunos
SELECT DISTINCT *, 
       CAST(current_timestamp AS TIMESTAMP) AS data_ingestao
FROM db_raw_alfabetizacao.alunos;
