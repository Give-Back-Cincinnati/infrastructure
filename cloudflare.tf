variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_key" {
  type = string
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key

}

locals {
  url = "givebackcincinnati.org"
}

data "cloudflare_zones" "gbc" {
  filter {
    name = local.url
  }
}

locals {
  zone_id = lookup(data.cloudflare_zones.gbc.zones[0], "id")
}

resource "cloudflare_record" "gbc_api" {
  zone_id = local.zone_id
  name    = "api.${local.url}"
  value   = azurerm_public_ip.gbc.ip_address
  type    = "A"
  proxied = true
  ttl     = 1
}

resource "cloudflare_record" "vault" {
  zone_id = local.zone_id
  name    = "vault.${local.url}"
  value   = azurerm_public_ip.gbc.ip_address
  type    = "A"
  proxied = true
  ttl     = 1
}

resource "cloudflare_record" "gbc_next" {
  zone_id = local.zone_id
  name    = "next.${local.url}"
  value   = "website-aid.pages.dev"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_zone_settings_override" "gbc_dev_settings" {
  zone_id = local.zone_id
  settings {
    brotli = "on"
    minify {
      css  = "on"
      js   = "on"
      html = "on"
    }
    always_use_https = "on"
    websockets       = "on"
    ssl              = "strict"
  }
}

resource "cloudflare_page_rule" "www_redirect" {
  zone_id  = local.zone_id
  target   = "www.${local.url}"
  priority = 1

  actions {
    forwarding_url {
      url         = "https://${local.url}"
      status_code = "301"
    }
  }
}
