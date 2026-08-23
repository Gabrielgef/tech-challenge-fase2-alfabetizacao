
import boto3


def criar_crawler_camada_raw(nome_bucket, arn_da_role):
    # Conecta no serviço Glue
    glue_client = boto3.client('glue', region_name='us-east-1')
    
    nome_crawler = 'crawler_tech_challenge_raw'
    nome_banco_dados = 'db_raw_alfabetizacao' # Banco de dados que será criado no Glue Catalog para armazenar as tabelas catalogadas pelo Crawler
    caminho_s3 = f's3://{nome_bucket}/raw/batch/'
    
    print(f"Iniciando a criação do banco de dados '{nome_banco_dados}' e do Crawler...")

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
            Description='Crawler para catalogar todas as tabelas em CSV da camada RAW',
            Targets={
                'S3Targets': [
                    {
                        'Path': caminho_s3,
                    }
                ]
            },
            # Configuração para ele atualizar as tabelas se o schema mudar no futuro
            SchemaChangePolicy={
                'UpdateBehavior': 'UPDATE_IN_DATABASE',
                'DeleteBehavior': 'DEPRECATE_IN_DATABASE'
            }
        )
        print(f"✅ Crawler '{nome_crawler}' criado com sucesso e apontando para {caminho_s3}!")
        
    except glue_client.exceptions.AlreadyExistsException:
        print(f"ℹ️ O Crawler '{nome_crawler}' já existe.")
    except Exception as e:
        print(f"❌ Erro ao criar o crawler: {e}")

# ==========================================
# Execução do script
# ==========================================
if __name__ == "__main__":
    MEU_BUCKET = "<BUCKET_DO_USUARIO>" # Substitua pelo nome do bucket do usuário
    MINHA_ROLE_ARN = "<ARN_DA_ROLE_DO_USUARIO>" #substitua pelo ARN da role do usuário
    
    criar_crawler_camada_raw(MEU_BUCKET, MINHA_ROLE_ARN)