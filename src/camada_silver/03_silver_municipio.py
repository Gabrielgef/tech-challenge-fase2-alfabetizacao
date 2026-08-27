import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, current_timestamp, broadcast, coalesce, lit
from pyspark.sql.types import DoubleType, StringType


args = getResolvedOptions(sys.argv, ['JOB_NAME', 'BUCKET_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

bucket_name = args['BUCKET_NAME']

# 1. Leitura dos Dados
caminho_municipio_bronze = f"s3://{bucket_name}/bronze/municipio/"
caminho_dicionario_silver = f"s3://{bucket_name}/silver/dicionario/"

df_municipio_bronze = spark.read.parquet(caminho_municipio_bronze)
df_dicionario = spark.read.parquet(caminho_dicionario_silver)

# 2. Preparando os Dicionários
dict_serie = df_dicionario.filter(
    (col("id_tabela") == "municipio") & (col("nome_coluna") == "serie")
).select(col("chave").alias("chave_serie"), col("valor").alias("desc_serie"))

dict_rede = df_dicionario.filter(
    (col("id_tabela") == "municipio") & (col("nome_coluna") == "rede")
).select(col("chave").alias("chave_rede"), col("valor").alias("desc_rede"))

# 3. Transformações, Limpeza e Enriquecimento
df_silver_municipio = df_municipio_bronze.dropDuplicates(["ano", "id_municipio", "serie", "rede"])

# 3.1. Tipagem e Padronização Base
df_silver_municipio = (
    df_silver_municipio
    .withColumn("id_municipio", col("id_municipio").cast(StringType()))
    .withColumn("taxa_alfabetizacao", col("taxa_alfabetizacao").cast(DoubleType()))
    .withColumn("media_portugues", col("media_portugues").cast(DoubleType()))
)

# 3.2. Tratamento de Nulos (Iterando sobre as colunas de proporção)
for i in range(9):
    col_nome = f"proporcao_aluno_nivel_{i}"
    # Converte para Double e substitui nulos por 0.0 usando coalesce
    df_silver_municipio = df_silver_municipio.withColumn(
        col_nome, coalesce(col(col_nome).cast(DoubleType()), lit(0.0))
    )

# 3.3. Joins com Dicionários e Metadados
df_silver_municipio = (
    df_silver_municipio
    .join(broadcast(dict_serie), col("serie") == col("chave_serie"), "left")
    .join(broadcast(dict_rede), col("rede") == col("chave_rede"), "left")
    .withColumn("data_processamento_silver", current_timestamp())
    .drop("chave_serie", "chave_rede", "data_ingestao") 
)

# 4. Escrita na Camada Silver (Parquet)
caminho_municipio_silver = f"s3://{bucket_name}/silver/municipio/"

(
    df_silver_municipio.write
    .mode("overwrite")
    .format("parquet")
    .option("compression", "snappy")
    .partitionBy("ano")
    .save(caminho_municipio_silver)
)

job.commit()