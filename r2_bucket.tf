variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "r2_access_key" {
  type = string
}

variable "r2_secret_key" {
  type      = string
  sensitive = true
}

provider "aws" {
  access_key                  = var.r2_access_key
  secret_key                  = var.r2_secret_key
  region                      = "auto"
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  endpoints {
    s3 = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  }
}

resource "aws_s3_bucket" "cloudflare-bucket" {
  bucket = "gbc-static"
}
