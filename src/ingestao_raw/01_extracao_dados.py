import basedosdados as bd
import pandas as pd
import boto3
import os

def extrair_e_enviar_raw(db, nome_tabela, billing_id, nome_bucket):
    print(f"Iniciando a extração da tabela: {nome_tabela}...")

    # AVISO: O LIMIT 100 é ótimo para testar o código rápido. 
    # Lembre-se de remover a linha 'limit 100' quando for extrair os dados reais!
    query = f"""
        SELECT *
        FROM {db}
    """

    # 1. Extração do BigQuery (Base dos Dados)
    df = bd.read_sql(query=query, billing_project_id=billing_id)

    # 2. Salva exatamente como veio, em CSV puro (padrão camada RAW)
    arquivo_csv = f"{nome_tabela}.csv"
    df.to_csv(arquivo_csv, index=False, encoding='utf-8')
    print(f"✅ CSV bruto gerado localmente: {arquivo_csv}")

    # 3. Upload automático para o S3
    s3_client = boto3.client('s3')
    
    # Define a estrutura de pastas da camada Raw: raw/batch/nome_da_tabela/arquivo.csv
    caminho_s3 = f"raw/batch/{nome_tabela}/{arquivo_csv}"
    
    try:
        s3_client.upload_file(arquivo_csv, nome_bucket, caminho_s3)
        print(f"🚀 Upload concluído no S3: s3://{nome_bucket}/{caminho_s3}")
    except Exception as e:
        print(f"❌ Erro no upload para o S3: {e}")
        print("Verifique se as suas chaves do AWS CLI estão configuradas.")

    # 4. Limpa o arquivo local do Colab para não estourar o disco
    if os.path.exists(arquivo_csv):
        os.remove(arquivo_csv)


# ==========================================
# CONFIGURAÇÕES E EXECUÇÃO
# ==========================================

if __name__ == "__main__":
    
    billing_id = "<BILLING_ID>"  # Substitua pelo seu billing_id do BigQuery
    nome_do_seu_bucket = "<BUCKET_DO_USUARIO>" # Substitua pelo nome do seu bucket no S3

    # lista de tabelas a serem extraídas do BigQuery
    lista_tabelas = [
        '`basedosdados.br_inep_avaliacao_alfabetizacao.dicionario`',
        '`basedosdados.br_bd_diretorios_brasil.uf`',
        '`basedosdados.br_bd_diretorios_brasil.municipio`',
        '`basedosdados.br_inep_avaliacao_alfabetizacao.uf`',
        '`basedosdados.br_inep_avaliacao_alfabetizacao.meta_alfabetizacao_brasil`',
        '`basedosdados.br_inep_avaliacao_alfabetizacao.meta_alfabetizacao_uf`',
        '`basedosdados.br_inep_avaliacao_alfabetizacao.municipio`',
        '`basedosdados.br_inep_avaliacao_alfabetizacao.meta_alfabetizacao_municipio`',
        '`basedosdados.br_inep_avaliacao_alfabetizacao.alunos`'
    ]

    for tabela in lista_tabelas:
        # Separa o nome pelo ponto e pega a última parte, removendo as crases
        nome_limpo = tabela.split('.')[-1].replace('`', '')
        
        print(f"\n📥 Processando a fila: {nome_limpo}...")
        
        # Chama a função passando o nome limpo e armazena o dataframe resultante
        extrair_e_enviar_raw(
            db=tabela, 
            nome_tabela=nome_limpo, 
            billing_id=billing_id,
            nome_bucket=nome_do_seu_bucket
        )
    # Cria um arquivo vazio para avisar que a carga terminou e que a Step Function pode continuar
    s3_client = boto3.client('s3')
    s3_client.put_object(Bucket=nome_do_seu_bucket, Key='raw/batch/_SUCCESS.flag', Body='')
    
    print("Flag de sucesso enviada para o S3!")

    print("\n🎉 Ingestão da Camada RAW (Batch) Finalizada com Sucesso!")