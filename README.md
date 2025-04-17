## OpenShift Deployment Script

Este repositório contém um script para implantação automatizada de uma aplicação no Red Hat OpenShift Service on AWS (ROSA), com configuração de HPA (Horizontal Pod Autoscaler) e Volume Persistente.

## Descrição

O script `deploy-openshift.sh` implanta a aplicação `trabalho-final-cloud-builders` no projeto `wagner-damiao-dev`, configurando todos os recursos necessários para uma aplicação conteinerizada completa no OpenShift.

## Recursos criados

O script cria os seguintes recursos:

- **Persistent Volume Claim (PVC)**: Para armazenamento persistente de dados
- **Deployment**: Configurado com recursos, probes de saúde e volume montado
- **Service**: Para comunicação interna no cluster
- **Route**: Para acesso externo à aplicação
- **Horizontal Pod Autoscaler (HPA)**: Para escalabilidade automática baseada em utilização de CPU

## Pré-requisitos

- Acesso a um cluster Red Hat OpenShift Service on AWS (ROSA)
- Cliente OpenShift (`oc`) instalado e configurado
- Permissões apropriadas para criar recursos no namespace `wagner-damiao-dev`

## Como usar

1. Clone este repositório:
   ```bash
   git clone <url-do-repositorio>
   cd <nome-do-repositorio>

Dê permissão de execução ao script:
bashchmod +x deploy-openshift.sh

Execute o script:
bash./deploy-openshift.sh

Verifique a implantação:
bashoc get all -l app=trabalho-final-cloud-builders


Customização
Você pode personalizar a implantação editando as variáveis no início do script:
bash# Definição de variáveis
APP_NAME="trabalho-final-cloud-builders"
PROJECT="wagner-damiao-dev"
PVC_NAME="${APP_NAME}-pvc"
PVC_SIZE="1Gi"
VOLUME_MOUNT_PATH="/data"
IMAGE="quay.io/redhatworkshops/welcome-php:latest"  # Imagem de exemplo
Monitoramento
Após a execução do script, você pode monitorar a aplicação usando os seguintes comandos:
bash# Verificar pods em execução
oc get pods -l app=trabalho-final-cloud-builders

# Verificar status do HPA
oc get hpa trabalho-final-cloud-builders-hpa

# Verificar logs da aplicação
oc logs -f deployment/trabalho-final-cloud-builders
Limpeza
Para remover todos os recursos criados:
bashoc delete deployment,service,route,pvc,hpa -l app=trabalho-final-cloud-builders
Contribuição
Contribuições são bem-vindas! Por favor, sinta-se à vontade para enviar pull requests ou abrir issues para melhorias ou correções.
Licença
MIT

Este formato já está pronto para ser adicionado diretamente ao seu repositório Git como README.md.
