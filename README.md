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

[PULL SECRET](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-kubernetes#create-an-image-pull-secret)
1) Create a kubectl secret, see above link

# Setup Vault
1) Log in to vault: `kubectl exec -it -n vault gbc-vault-0 -- /bin/sh`
2) Run `vault operator init`
3) Save and distribute the unseal keys
4) `vault login` and enter the root token
5) Allow users to authenticate with username and password `vault auth enable userpass`
6) Create a username and password `vault write auth/userpass/users/[username] password='[insert strong password]' policies=admins`
7) Login as root (method: Token, enter root token) and create a new policy named "admins"
8) You can now create secrets engines



### TODO: 
Setup a cleanup script for ACR -- e.g. https://zimmergren.net/purging-container-images-from-azure-container-registry/
