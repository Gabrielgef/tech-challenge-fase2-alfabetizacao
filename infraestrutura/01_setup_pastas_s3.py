import boto3

def configurar_estrutura_s3(nome_do_bucket):
    """
    Cria a estrutura de pastas da Arquitetura Medalhão no S3.
    """
    s3_client = boto3.client('s3')
    
    # Definindo a arquitetura de pastas
    pastas_necessarias = [
        'bronze/',
        'silver/',
        'gold/',
        'raw/',
        'quality_reports/'
    ]
    
    print(f"🚀 Configurando o Data Lake no bucket: '{nome_do_bucket}'...\n")
    
    try:
        for pasta in pastas_necessarias:
            s3_client.put_object(Bucket=nome_do_bucket, Key=pasta)
            print(f"📁 Pasta criada: s3://{nome_do_bucket}/{pasta}")
            
        print("\n✅ Estrutura do Data Lake criada com sucesso!")
        
    except Exception as e:
        print(f"\n❌ Erro ao criar a estrutura no S3: {e}")

# ==========================================
# Execução do script
# ==========================================
if __name__ == "__main__":
    bucket_usuario = "<BUCKET_DO_USUARIO>"  # Substitua pelo nome do bucket do usuário
    configurar_estrutura_s3(bucket_usuario)