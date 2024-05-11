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
#curl -s -X POST \
#    --url http://localhost:8001/routes/cep/plugins/ \
#    --data 'name=rinha'

# Add service to Kong
curl -s -X POST \
    --url http://localhost:8001/services/ \
    --data 'name=postman' \
    --data 'url=http://postman-echo.com/'
# Add routes to Kong
curl -s -X POST \
    --url http://localhost:8001/services/postman/routes \
    --data 'name=meuget' \
    --data 'paths[]=/get' \
    --data 'strip_path=false' \
    --data 'methods[]=GET'
curl -s -X POST \
    --url http://localhost:8001/services/postman/routes \
    --data 'name=meupost' \
    --data 'paths[]=/post' \
    --data 'strip_path=false' \
    --data 'methods[]=POST'
# Add plugins to route
curl -s -X POST \
    --url http://localhost:8001/routes/meupost/plugins/ \
    --data 'name=rinha'
curl -s -X POST \
    --url "http://localhost:8001/routes/meupost/plugins/" \
    --data name="file-log" \
    --data config.path="/dev/stdout"