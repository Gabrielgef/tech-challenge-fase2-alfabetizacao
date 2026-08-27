import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, translate, upper, trim, current_timestamp


args = getResolvedOptions(sys.argv, ['JOB_NAME', 'BUCKET_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

bucket = args['BUCKET_NAME']

# Habilitar o catálogo do Glue para criar as tabelas direto no Athena
spark.conf.set("hive.metastore.client.factory.class", "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory")

# Função para remover acentos e padronizar
def limpar_texto(coluna):
    acentos = "áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ"
    sem_acentos = "aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC"
    return trim(upper(translate(col(coluna), acentos, sem_acentos)))

# ==========================================
# PROCESSAMENTO: DIM_UF (BRONZE -> SILVER)
# ==========================================
caminho_uf_bronze = f"s3://{bucket}/bronze/dim_uf/"
caminho_uf_silver = f"s3://{bucket}/silver/dim_uf/"

# Lendo a Bronze
df_uf_bronze = spark.read.parquet(caminho_uf_bronze)

# Aplicando a limpeza
df_uf_silver = (
    df_uf_bronze
    .dropDuplicates(["sigla"]) 
    .withColumn("nome", limpar_texto("nome"))
    .withColumn("data_processamento_silver", current_timestamp())
    .drop("data_ingestao")
)

# Salvando no S3 e criando a tabela db_silver_alfabetizacao.dim_uf
(df_uf_silver.write
 .mode("overwrite")
 .format("parquet")
 .option("compression", "snappy")
 .option("path", caminho_uf_silver) 
 .saveAsTable("db_silver_alfabetizacao.dim_uf"))

# ==========================================
# PROCESSAMENTO: DIM_MUNICIPIO (BRONZE -> SILVER)
# ==========================================
caminho_mun_bronze = f"s3://{bucket}/bronze/dim_municipio/"
caminho_mun_silver = f"s3://{bucket}/silver/dim_municipio/"

# Lendo a Bronze
df_mun_bronze = spark.read.parquet(caminho_mun_bronze)

# Aplicando a limpeza
df_mun_silver = (
    df_mun_bronze
    .dropDuplicates(["id_municipio"]) 
    .withColumn("nome", limpar_texto("nome")) 
    .withColumn("data_processamento_silver", current_timestamp())
    .drop("data_ingestao")
)

# Salvando no S3 e criando a tabela db_silver_alfabetizacao.dim_municipio
(df_mun_silver.write
 .mode("overwrite")
 .format("parquet")
 .option("compression", "snappy")
 .option("path", caminho_mun_silver) 
 .saveAsTable("db_silver_alfabetizacao.dim_municipio"))

job.commit()