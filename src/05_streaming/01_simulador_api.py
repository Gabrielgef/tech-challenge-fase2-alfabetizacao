import requests
import time
import json
import csv
from datetime import datetime

# Substitua pela URL do seu API Gateway gerada na AWS

API_URL = "https://sua-url-do-api-gateway.amazonaws.com/default/sua-funcao"
CAMINHO_ARQUIVO = "data/amostras/alunos_streaming.csv"


print(f"Lendo base de dados: {CAMINHO_ARQUIVO}")
print("Iniciando streaming para a AWS. Pressione Ctrl+C para parar.\n")

try:
    with open(CAMINHO_ARQUIVO, mode='r', encoding='utf-8') as file:
        leitor_csv = csv.DictReader(file)
        
        for linha in leitor_csv:
            payload = dict(linha) 
            
            # Atualiza o timestamp para simular que a prova acabou de ser entregue
            payload['timestamp_envio'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            try:
                # Dispara para o API Gateway
                response = requests.post(API_URL, json=payload, timeout=5)
                
                if response.status_code == 200:
                    print(f"[SUCESSO] Aluno enviado em tempo real!")
                else:
                    print(f"[ERRO] Falha na AWS. Status: {response.status_code}")
                    
            except requests.exceptions.RequestException:
                print("\n[ALERTA] AWS Inacessível. O Lab do Academy está ligado?")
                time.sleep(5)
            
            # Aguarda 2 segundos para simular o fluxo de rede
            time.sleep(2)
            
except FileNotFoundError:
    print(f"Erro: Arquivo {CAMINHO_ARQUIVO} não encontrado.")