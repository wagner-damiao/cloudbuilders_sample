#!/bin/bash
# Script para implantação de aplicação no OpenShift com HPA e Volume Persistente
# Nome do projeto: wagner-damiao-dev
# Nome da aplicação: trabalho-final-cloud-builders

# Definição de variáveis
APP_NAME="trabalho-final-cloud-builders"
PROJECT="wagner-damiao-dev"
PVC_NAME="${APP_NAME}-pvc"
PVC_SIZE="1Gi"
VOLUME_MOUNT_PATH="/data"
IMAGE="quay.io/redhatworkshops/welcome-php:latest"  # Imagem de exemplo

echo "=== Iniciando implantação de $APP_NAME no projeto $PROJECT ==="

# Verificar e usar o projeto correto
echo "Verificando projeto..."
oc project $PROJECT || oc new-project $PROJECT

# Criar Persistent Volume Claim (PVC)
echo "Criando Persistent Volume Claim..."
cat << EOF | oc create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${PVC_NAME}
  namespace: ${PROJECT}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: ${PVC_SIZE}
EOF

# Criar Deployment
echo "Criando Deployment..."
cat << EOF | oc create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
  namespace: ${PROJECT}
  labels:
    app: ${APP_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
      - name: ${APP_NAME}
        image: ${IMAGE}
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        volumeMounts:
        - name: data-volume
          mountPath: ${VOLUME_MOUNT_PATH}
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 10
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: ${PVC_NAME}
EOF

# Criar Serviço
echo "Criando Serviço..."
cat << EOF | oc create -f -
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}
  namespace: ${PROJECT}
  labels:
    app: ${APP_NAME}
spec:
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    app: ${APP_NAME}
EOF

# Criar Rota
echo "Criando Rota..."
cat << EOF | oc create -f -
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: ${APP_NAME}
  namespace: ${PROJECT}
  labels:
    app: ${APP_NAME}
spec:
  to:
    kind: Service
    name: ${APP_NAME}
  port:
    targetPort: 8080
EOF

# Configurar HPA (Horizontal Pod Autoscaler)
echo "Configurando Horizontal Pod Autoscaler..."
cat << EOF | oc create -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ${APP_NAME}-hpa
  namespace: ${PROJECT}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${APP_NAME}
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

# Verificar os recursos criados
echo "===== Verificando recursos criados ====="
echo "Verificando PVC..."
oc get pvc ${PVC_NAME}

echo "Verificando Deployment..."
oc get deployment ${APP_NAME}

echo "Verificando Pods..."
oc get pods -l app=${APP_NAME}

echo "Verificando Serviço..."
oc get svc ${APP_NAME}

echo "Verificando Rota..."
oc get route ${APP_NAME}

echo "Verificando HPA..."
oc get hpa ${APP_NAME}-hpa

# Obter URL da aplicação
APP_URL=$(oc get route ${APP_NAME} -o jsonpath='{.spec.host}')
echo "===== Implantação completa! ====="
echo "A aplicação ${APP_NAME} está disponível em: http://${APP_URL}"
echo "Para verificar os logs: oc logs -f deployment/${APP_NAME}"
