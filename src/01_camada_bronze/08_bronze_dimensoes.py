import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import current_timestamp

# ==========================================
# Carrega as bases dimensão Uf e Municipio 
# do S3 RAW para a camada Bronze
# ==========================================

# 1. Inicialização
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'BUCKET_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

bucket = args['BUCKET_NAME']

# ==========================================
# PROCESSAMENTO: DIM_UF (RAW -> BRONZE)
# ==========================================
caminho_uf_raw = f"s3://{bucket}/raw/dim_uf/"
caminho_uf_bronze = f"s3://{bucket}/bronze/dim_uf/"

# Lendo o CSV
df_uf_raw = spark.read.option("header", "true").option("delimiter", ",").csv(caminho_uf_raw)

df_uf_bronze = df_uf_raw.withColumn("data_ingestao", current_timestamp())

(df_uf_bronze.write
 .mode("overwrite")
 .format("parquet")
 .option("compression", "snappy")
 .option("path", caminho_uf_bronze)
 .saveAsTable("db_bronze_alfabetizacao.dim_uf"))

# ==========================================
# PROCESSAMENTO: DIM_MUNICIPIO (RAW -> BRONZE)
# ==========================================
caminho_mun_raw = f"s3://{bucket}/raw/dim_municipio/"
caminho_mun_bronze = f"s3://{bucket}/bronze/dim_municipio/"

# Lendo o CSV
df_mun_raw = spark.read.option("header", "true").option("delimiter", ",").csv(caminho_mun_raw)

df_mun_bronze = df_mun_raw.withColumn("data_ingestao", current_timestamp())

(df_mun_bronze.write
 .mode("overwrite")
 .format("parquet")
 .option("compression", "snappy")
 .option("path", caminho_mun_bronze)
 .saveAsTable("db_bronze_alfabetizacao.dim_municipio"))

job.commit()