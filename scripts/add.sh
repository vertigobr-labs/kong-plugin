#!/bin/sh

echo "Instalando plugin e rota de teste..."

# Add service to Kong
curl -s -X POST \
    --url http://localhost:8001/services/ \
    --data 'name=viacep' \
    --data 'url=http://viacep.com.br/ws/'

# Add route to Kong
curl -s -X POST \
    --url http://localhost:8001/services/viacep/routes \
    --data 'name=cep' \
    --data 'paths[]=/cep' \
    --data 'methods[]=GET'

# Add plugin to route
curl -s -X POST \
    --url http://localhost:8001/routes/cep/plugins/ \
    --data 'name=rinha'
