import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, current_timestamp
from pyspark.sql.types import DoubleType, IntegerType


args = getResolvedOptions(sys.argv, ['JOB_NAME', 'BUCKET_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

bucket_name = args['BUCKET_NAME']

# 1. Leitura dos Dados na Camada Bronze
caminho_bronze = f"s3://{bucket_name}/bronze/meta_alfabetizacao_brasil/"
df_bronze = spark.read.parquet(caminho_bronze)

# 2. Transformações, Limpeza e Tipagem
# Removemos duplicatas baseadas na chave lógica (ano e rede)
df_silver = df_bronze.dropDuplicates(["ano", "rede"])

# 2.1. Convertendo o ano para Inteiro
df_silver = df_silver.withColumn("ano", col("ano").cast(IntegerType()))

# 2.2. Convertendo todas as métricas e metas para Double (Decimais)
colunas_decimais = [
    "taxa_alfabetizacao", "meta_alfabetizacao_2024", "meta_alfabetizacao_2025",
    "meta_alfabetizacao_2026", "meta_alfabetizacao_2027", "meta_alfabetizacao_2028",
    "meta_alfabetizacao_2029", "meta_alfabetizacao_2030", "percentual_participacao"
]

for coluna in colunas_decimais:
    df_silver = df_silver.withColumn(coluna, col(coluna).cast(DoubleType()))

# 2.3. Adicionando metadados e removendo colunas da Bronze
df_silver = (
    df_silver
    .withColumn("data_processamento_silver", current_timestamp())
    .drop("data_ingestao")
)

# 3. Escrita na Camada Silver (Parquet)
caminho_silver = f"s3://{bucket_name}/silver/meta_alfabetizacao_brasil/"

(
    df_silver.write
    .mode("overwrite")  # Sobrescrevemos a tabela inteira, já que é uma tabela de parâmetros pequena
    .format("parquet")
    .option("compression", "snappy")
    .save(caminho_silver)
)

job.commit()