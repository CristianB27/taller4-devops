#!/usr/bin/env bash
# Prepara en Azure todo lo necesario ANTES de correr el pipeline.
# Requiere: az CLI autenticado (az login), rol Owner en la suscripción
# y permiso para crear App Registrations en Microsoft Entra ID.
set -euo pipefail

# ======== EDITA ESTAS VARIABLES ========
GITHUB_ORG="CristianB27"
GITHUB_REPO="taller4-devops"
LOCATION="eastus"
PROJECT="taller4"
TFSTATE_RG="rg-${PROJECT}-tfstate"
TFSTATE_SA="st${PROJECT}tfstate${RANDOM}"   # único global, 3-24 chars, minúsculas y números
# =======================================

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
TENANT_ID="$(az account show --query tenantId -o tsv)"
echo ">> Suscripción: ${SUBSCRIPTION_ID}"

echo ">> Registrando resource providers..."
for ns in Microsoft.Web Microsoft.ContainerRegistry Microsoft.Storage Microsoft.Authorization; do
  az provider register --namespace "$ns" --wait
done

echo ">> Backend de Terraform..."
az group create -n "$TFSTATE_RG" -l "$LOCATION" -o none
az storage account create -n "$TFSTATE_SA" -g "$TFSTATE_RG" -l "$LOCATION" \
  --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 \
  --allow-blob-public-access false -o none
az storage account blob-service-properties update \
  --account-name "$TFSTATE_SA" -g "$TFSTATE_RG" --enable-versioning true -o none

SA_ID="$(az storage account show -n "$TFSTATE_SA" -g "$TFSTATE_RG" --query id -o tsv)"

for ENV in dev prod; do
  echo ">> Ambiente: ${ENV}"
  RG="rg-${PROJECT}-${ENV}"

  az group create -n "$RG" -l "$LOCATION" -o none
  az storage container create --name "tfstate-${ENV}" \
    --account-name "$TFSTATE_SA" --auth-mode key -o none

  # App Registration + Service Principal propios del ambiente
  APP_ID="$(az ad app create --display-name "sp-${PROJECT}-${ENV}-github" --query appId -o tsv)"
  az ad sp create --id "$APP_ID" -o none
  SP_OBJ_ID="$(az ad sp show --id "$APP_ID" --query id -o tsv)"
  sleep 20 # propagación en Entra ID

  # Credencial federada (OIDC): solo el Environment de GitHub con ese nombre puede autenticarse
  az ad app federated-credential create --id "$APP_ID" --parameters "{
    \"name\": \"github-${ENV}\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:${GITHUB_ORG}/${GITHUB_REPO}:environment:${ENV}\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }" -o none

  RG_ID="$(az group show -n "$RG" --query id -o tsv)"
  for ROLE in "Contributor" "User Access Administrator"; do
    az role assignment create --assignee-object-id "$SP_OBJ_ID" \
      --assignee-principal-type ServicePrincipal --role "$ROLE" --scope "$RG_ID" -o none
  done

  # Solo puede tocar SU contenedor de estado
  az role assignment create --assignee-object-id "$SP_OBJ_ID" \
    --assignee-principal-type ServicePrincipal --role "Storage Blob Data Contributor" \
    --scope "${SA_ID}/blobServices/default/containers/tfstate-${ENV}" -o none

  echo "AZURE_CLIENT_ID_${ENV}=${APP_ID}" >> bootstrap-output.txt
done

{
  echo "AZURE_TENANT_ID=${TENANT_ID}"
  echo "AZURE_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}"
  echo "TFSTATE_RG=${TFSTATE_RG}"
  echo "TFSTATE_SA=${TFSTATE_SA}"
} >> bootstrap-output.txt

echo
echo "================ VALORES PARA GITHUB (guardados en bootstrap-output.txt) ================"
cat bootstrap-output.txt
