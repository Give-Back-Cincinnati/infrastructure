## Get kubeconfig for the cluster
`az aks get-credentials --admin --name [name]-aks --resource-group [name]-resources`

## [Allowing DNS validation for LetsEncrypt](https://cert-manager.io/docs/tutorials/acme/dns-validation/)
1) Run `kubectl create secret generic cloudflare-api-key-secret --from-literal=api-key=<api_key_goes_here>  --namespace=cert-manager` to add the cloudflare API secret to the cluster for use by the issuer
2) Run `kubectl apply -f ./k8s-resources/cert-manager`

## [NGINX ingress documentation](https://github.com/bitnami/charts/tree/master/bitnami/nginx-ingress-controller)

## Get Credentials
REGISTRY_LOGIN_SERVER: get from Azure portal or terraform
REGISTRY_USERNAME & REGISTRY_PASSWORD:
1) `az acr credential show --name [name]CR`
2) copy password & username to secrets
   
AZURE_CREDENTIALS:
1) `az ad sp create-for-rbac --name "[name]-actions-user" --sdk-auth --role contributor \
   --scopes /subscriptions/[subscription_id]/resourceGroups/[name]-resources
   `
2) copy the output to a secret named AZURE_CREDENTIALS
  NOTE: https://github.com/Azure/login#configure-deployment-credentials

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

### TODO: 
Setup a cleanup script for ACR -- e.g. https://zimmergren.net/purging-container-images-from-azure-container-registry/
