import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, current_timestamp, broadcast
from pyspark.sql.types import IntegerType, StringType, DoubleType

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'BUCKET_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

bucket_name = args['BUCKET_NAME']

# 1. Leitura dos Dados
caminho_alunos_bronze = f"s3://{bucket_name}/bronze/alunos/"
caminho_dicionario_silver = f"s3://{bucket_name}/silver/dicionario/"

df_alunos_bronze = spark.read.parquet(caminho_alunos_bronze)
df_dicionario = spark.read.parquet(caminho_dicionario_silver)

# 2. Preparando os Dicionários via Broadcast (Filtro 'alunos')
dict_base = df_dicionario.filter(col("id_tabela") == "alunos")

def criar_dicionario(nome_coluna, alias_chave, alias_desc):
    return dict_base.filter(col("nome_coluna") == nome_coluna) \
                    .select(col("chave").alias(alias_chave), col("valor").alias(alias_desc))

dict_serie = criar_dicionario("serie", "chave_serie", "desc_serie")
dict_rede = criar_dicionario("rede", "chave_rede", "desc_rede")
dict_presenca = criar_dicionario("presenca", "chave_pres", "desc_presenca")
dict_preench = criar_dicionario("preenchimento_caderno", "chave_preench", "desc_preenchimento")
dict_alfabetizado = criar_dicionario("alfabetizado", "chave_alfa", "desc_alfabetizado")

# 3. Limpeza, Tipagem e Unicidade
# A chave primária é o aluno em um determinado ano
df_silver_alunos = df_alunos_bronze.dropDuplicates(["ano", "id_aluno"])

df_silver_alunos = (
    df_silver_alunos
    .withColumn("ano", col("ano").cast(IntegerType()))
    .withColumn("id_municipio", col("id_municipio").cast(StringType()))
    .withColumn("id_escola", col("id_escola").cast(StringType()))
    .withColumn("id_aluno", col("id_aluno").cast(StringType()))
    .withColumn("caderno", col("caderno").cast(StringType()))
    .withColumn("proficiencia", col("proficiencia").cast(DoubleType()))
    .withColumn("peso_aluno", col("peso_aluno").cast(DoubleType()))
)

# 4. Enriquecimento (Broadcast Joins)
df_silver_alunos = (
    df_silver_alunos
    .join(broadcast(dict_serie), col("serie") == col("chave_serie"), "left")
    .join(broadcast(dict_rede), col("rede") == col("chave_rede"), "left")
    .join(broadcast(dict_presenca), col("presenca") == col("chave_pres"), "left")
    .join(broadcast(dict_preench), col("preenchimento_caderno") == col("chave_preench"), "left")
    .join(broadcast(dict_alfabetizado), col("alfabetizado") == col("chave_alfa"), "left")
    
    # 4.1 Adicionando metadados e removendo colunas temporárias/brutas
    .withColumn("data_processamento_silver", current_timestamp())
    .drop(
        "chave_serie", "chave_rede", "chave_pres", "chave_preench", "chave_alfa", 
        "data_ingestao"
    )
)

# 5. Escrita na Camada Silver (Parquet Particionado)
caminho_alunos_silver = f"s3://{bucket_name}/silver/alunos/"

(
    df_silver_alunos.write
    .mode("overwrite")
    .format("parquet")
    .option("compression", "snappy")
    .partitionBy("ano") 
    .save(caminho_alunos_silver)
)

job.commit()