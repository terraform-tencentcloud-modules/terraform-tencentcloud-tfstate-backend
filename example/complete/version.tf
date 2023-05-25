terraform {
  required_version = ">= 0.12"

    required_providers {
      tencentcloud = {
        source  = "tencentcloudstack/tencentcloud"
        version = ">1.18.1"
      }
      local = {
        source  = "hashicorp/local"
        version = "= 2.2.0"
      }
    }
}
provider "tencentcloud" {
  region = "ap-guangzhou"
  # secret_id = "my-secret-id"
  # secret_key = "my-secret-key"
}


