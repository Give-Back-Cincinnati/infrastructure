## Get kubeconfig for the cluster
`az aks get-credentials --admin --name studyhall-aks --resource-group studyhall-resources`

## [Allowing DNS validation for LetsEncrypt](https://cert-manager.io/docs/tutorials/acme/dns-validation/)
1) Run `kubectl create secret generic cloudflare-api-key-secret --from-literal=api-key=<api_key_goes_here>  --namespace=cert-manager` to add the cloudflare API secret to the cluster for use by the issuer
2) Run `kubectl apply -f ./k8s-resources/cert-manager`

## [NGINX ingress documentation](https://github.com/bitnami/charts/tree/master/bitnami/nginx-ingress-controller)

## Setup nats.io for PIXIE
`kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/vizier_deps/base/nats/nats_crd.yaml`

## Get Credentials
REGISTRY_LOGIN_SERVER: get from Azure portal or terraform
REGISTRY_USERNAME & REGISTRY_PASSWORD:
1) `az acr credential show --name studyhallCR`
2) copy password & username to secrets
   
AZURE_CREDENTIALS:
1) `az ad sp create-for-rbac --name "studyhall-actions-user" --sdk-auth --role contributor \
   --scopes /subscriptions/[subscription_id]/resourceGroups/studyhall-resources
   `
2) copy the output to a secret named AZURE_CREDENTIALS
  NOTE: https://github.com/Azure/login#configure-deployment-credentials

POSTGRESQL_URL:
1) navigate to the PSQL server in Azure
2) navigate to Properties
3) Format into string: `pgsql://studyhallAdmin@studyhall-psqlserver:[password]@studyhall-psqlserver.postgres.database.azure.com/postgres?serverVersion=11`

# ORGANIZATION SECRETS
- CLUSTER_NAME = studyhall-aks
- CLUSTER_RESOURCE_GROUP = studyhall-resources
- NAMESPACE_PROD = prod
- NAMESPACE_STAGE = stage
- REGISTRY_LOGIN_SERVER = studyhallcr.azurecr.io
- REGISTRY_USERNAME = studyhallCR
- REGISTRY_PASSWORD = usXtRucFnM=dGrhqRilEYoiWMHNpOd92
- AZURE_CREDENTIALS = {"clientId": "81246666-ce89-4c78-854d-f1f1d551e8f1",
"clientSecret": "c0118286-6088-48f2-8185-ca792e245ed2",
"subscriptionId": "10d02868-1f42-4b0f-85d7-53d8abaec4e1",
"tenantId": "e1d944d5-282f-4fe5-95db-7f12140b2fbc",
"activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
"resourceManagerEndpointUrl": "https://management.azure.com/",
"activeDirectoryGraphResourceId": "https://graph.windows.net/",
"sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
"galleryEndpointUrl": "https://gallery.azure.com/",
"managementEndpointUrl": "https://management.core.windows.net/"}
- PULL_SECRET = studyhall
- POSTGRESQL_URL = pgsql://studyhallAdmin@studyhall-psqlserver:suwxew-Rodrub-8pofvo@studyhall-psqlserver.postgres.database.azure.com/postgres?serverVersion=11

# ENV Variables
APP_NAME = studyhall
APP_URL = studyhall.dev

# Helm commands
Upgrade:
```bash
helm upgrade studyhall --reuse-values helm/api-platform/ --namespace=${{ secrets.NAMESPACE_PROD }} \
--set php.image.tag="${{ github.sha }}" \
--set php.corsAllowOrigin='^https?://[a-z\]*\.${{ env.APP_URL }}$' \
--set caddy.image.tag="${{ github.sha }}" \
--set postgresql.url="${{ secrets.POSTGRESQL_URL }}" \
--set imagePullSecrets[0].name=${{ secrets.PULL_SECRET }}
```

## Setting up New Relic - Pixie

```
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/crd/base/px.dev_viziers.yaml && \
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/helm/crds/olm_crd.yaml
```


### TODO: 
Setup a cleanup script for ACR -- e.g. https://zimmergren.net/purging-container-images-from-azure-container-registry/