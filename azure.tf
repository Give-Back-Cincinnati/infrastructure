variable "az_client_id" {
  type = string
}

variable "az_client_secret" {
  type = string
}

variable "az_tenant_id" {
  type = string
}

variable "az_subscription_id" {
  type = string
}

variable "name_prefix" {
  type    = string
  default = "gbc"
}

provider "azurerm" {
  features {}
  client_id       = var.az_client_id
  client_secret   = var.az_client_secret
  tenant_id       = var.az_tenant_id
  subscription_id = var.az_subscription_id
}

resource "azurerm_resource_group" "gbc" {
  name = "gbc-resources"
  // DO NOT CHANGE THIS WITHOUT ALSO CHANGING THE MONGODB ATLAS REGION
  // reference https://docs.atlas.mongodb.com/reference/microsoft-azure/
  location = "East US"
}

resource "azurerm_container_registry" "acr" {
  name                = "gbcCR"
  resource_group_name = azurerm_resource_group.gbc.name
  location            = azurerm_resource_group.gbc.location
  sku                 = "Standard"

  admin_enabled = true
}

resource "azurerm_virtual_network" "gbc_vnet" {
  name                = "${var.name_prefix}-vnet"
  address_space       = ["10.1.0.0/16"]
  resource_group_name = azurerm_resource_group.gbc.name
  location            = azurerm_resource_group.gbc.location
}

resource "azurerm_subnet" "gbc_subnet" {
  name                 = "${var.name_prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.gbc_vnet.name
  resource_group_name  = azurerm_resource_group.gbc.name
  address_prefixes     = ["10.1.0.0/22"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_kubernetes_cluster" "gbc" {
  name                = "${var.name_prefix}-aks"
  location            = azurerm_resource_group.gbc.location
  resource_group_name = azurerm_resource_group.gbc.name
  dns_prefix          = "${var.name_prefix}-dns"

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = true
    max_count           = 2
    min_count           = 1
    vnet_subnet_id      = azurerm_subnet.gbc_subnet.id
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"
  }

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_resource_group" "aks_resource_group" {
  name = azurerm_kubernetes_cluster.gbc.node_resource_group
}

resource "azurerm_public_ip" "gbc" {
  name                = "${var.name_prefix}PublicIp"
  resource_group_name = data.azurerm_resource_group.aks_resource_group.name
  location            = data.azurerm_resource_group.aks_resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# need to add a vnet for mongodb atlas

output "client_certificate" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.gbc.kube_config.0.client_certificate
}

output "kube_config" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.gbc.kube_config_raw
}