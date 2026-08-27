import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, trim, current_timestamp, lower, upper, translate, regexp_replace

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'BUCKET_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

bucket_name = args['BUCKET_NAME']


# 1. FUNÇÃO DE LIMPEZA DE TEXTO
def limpar_texto_pesado(coluna):
    # 1.1 Remove aspas simples e duplas usando Regex
    sem_aspas = regexp_replace(col(coluna), "[\"']", "")
    
    # 1.2 Mapa de caracteres para remover acentos
    acentos = "áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ"
    sem_acentos = "aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC"
    
    # 1.3 Traduz caracteres e aplica maiúsculo com trim
    texto_sem_acento = translate(sem_aspas, acentos, sem_acentos)
    return trim(upper(texto_sem_acento))

# 2. Leitura dos Dados na Camada Bronze
caminho_bronze = f"s3://{bucket_name}/bronze/dicionario/"
df_bronze = spark.read.parquet(caminho_bronze)

# 3. Transformações da Camada Silver
df_silver = (
    df_bronze
    # Desduplicação estrita para evitar falhas nos Joins futuros
    .dropDuplicates(["id_tabela", "nome_coluna", "chave"])
    
    # Padronização de strings (Trim para remover espaços extras e lower para chaves)
    .withColumn("id_tabela", lower(trim(col("id_tabela"))))
    .withColumn("nome_coluna", lower(trim(col("nome_coluna"))))
    
    # Limpeza pesada na coluna valor (Sem aspas, sem acentos, maiúsculo)
    .withColumn("valor", limpar_texto_pesado("valor"))
    
    # Adicionando metadados de auditoria da camada Silver
    .withColumn("data_processamento_silver", current_timestamp())
    
    # Removendo colunas de controle da Bronze que não são úteis aqui
    .drop("data_ingestao")
)

# 4. Escrita na Camada Silver (Parquet)
caminho_silver = f"s3://{bucket_name}/silver/dicionario/"

(
    df_silver.write
    .mode("overwrite")
    .format("parquet")
    .option("compression", "snappy")
    .save(caminho_silver)
)

job.commit()