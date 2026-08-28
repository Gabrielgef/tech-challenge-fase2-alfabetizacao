import json
import boto3
import datetime
import uuid

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    BUCKET_NAME = '<NOME_BUCKET>'
    
    try:
        body = json.loads(event.get('body', '{}'))
        
        # Cria um nome de arquivo único para não sobrescrever
        timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        file_name = f"raw/streaming/aluno_{timestamp}_{str(uuid.uuid4())[:8]}.json"
        
        # Salva o JSON no S3
        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=file_name,
            Body=json.dumps(body),
            ContentType='application/json'
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps(f'Evento salvo com sucesso: {file_name}')
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Erro interno: {str(e)}')
        }
