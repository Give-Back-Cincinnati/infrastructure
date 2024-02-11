
<img width="959" alt="Screenshot 2024-02-11 at 2 04 39 PM" src="https://github.com/Give-Back-Cincinnati/infrastructure/assets/16326908/1face15d-cfab-4b40-b354-05dce04aad53">


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

# Setup Secret Injection via Vault
1) `vault auth enable kubernetes`
2) Add a policy for apps to read secrets e.g.
    ```
    path "prod/*" {
    capabilities = ["read"]
    }

    path "stage/*" {
    capabilities = ["read"]
    }
    ```
1)  Create config for k8s authentication
    ```
    vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```
1) Create "myapp" role and give it a name
```
vault write auth/kubernetes/role/myapp \
bound_service_account_names=app \
bound_service_account_namespaces=demo \
policies=app \
ttl=1h
```
2) 


### TODO: 
Setup a cleanup script for ACR -- e.g. https://zimmergren.net/purging-container-images-from-azure-container-registry/
