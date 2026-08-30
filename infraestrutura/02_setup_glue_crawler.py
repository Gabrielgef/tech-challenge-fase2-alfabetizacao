import boto3

def configurar_crawler_glue(glue_client, nome_bucket, arn_da_role, nome_banco_dados, nome_crawler, sub_pasta_s3):
    caminho_s3 = f's3://{nome_bucket}/{sub_pasta_s3}/'
    
    print(f"\n--- Configurando: {nome_crawler} ---")

    # 1. Cria o banco de dados no Glue Catalog (se não existir)
    try:
        glue_client.create_database(
            DatabaseInput={'Name': nome_banco_dados}
        )
        print(f"✅ Banco de dados '{nome_banco_dados}' criado no Data Catalog!")
    except glue_client.exceptions.AlreadyExistsException:
        print(f"ℹ️ O banco '{nome_banco_dados}' já existe. Seguindo...")

    # 2. Cria o Crawler
    try:
        glue_client.create_crawler(
            Name=nome_crawler,
            Role=arn_da_role,
            DatabaseName=nome_banco_dados,
            Description=f'Crawler para catalogar as tabelas da camada {sub_pasta_s3}',
            Targets={
                'S3Targets': [
                    {
                        'Path': caminho_s3,
                    }
                ]
            },
            SchemaChangePolicy={
                'UpdateBehavior': 'UPDATE_IN_DATABASE',
                'DeleteBehavior': 'DEPRECATE_IN_DATABASE'
            }
        )
        print(f"✅ Crawler '{nome_crawler}' criado com sucesso apontando para {caminho_s3}!")
        
    except glue_client.exceptions.AlreadyExistsException:
        print(f"ℹ️ O Crawler '{nome_crawler}' já existe.")
    except Exception as e:
        print(f"❌ Erro ao criar o crawler: {e}")

# ==========================================
# Execução do script
# ==========================================
if __name__ == "__main__":
    MEU_BUCKET = "<BUCKET_DO_USUARIO>" # Substitua pelo nome do seu bucket
    MINHA_ROLE_ARN = "<ARN_DA_ROLE_DO_USUARIO>" # Substitua pelo ARN da sua LabRole
    
    # Inicia o cliente do Glue uma única vez
    glue_client = boto3.client('glue', region_name='us-east-1')
    
    # 1. Cria o Crawler da camada RAW
    configurar_crawler_glue(
        glue_client=glue_client,
        nome_bucket=MEU_BUCKET,
        arn_da_role=MINHA_ROLE_ARN,
        nome_banco_dados='db_raw_alfabetizacao',
        nome_crawler='crawler_tech_challenge_raw',
        sub_pasta_s3='raw/batch'
    )
    
    # 2. Cria o Crawler da camada SILVER
    configurar_crawler_glue(
        glue_client=glue_client,
        nome_bucket=MEU_BUCKET,
        arn_da_role=MINHA_ROLE_ARN,
        nome_banco_dados='db_silver_alfabetizacao',
        nome_crawler='crawler_tech_challenge_silver',
        sub_pasta_s3='silver'
    )