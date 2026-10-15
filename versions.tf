terraform {
  required_version = ">= 1.4.0"

  required_providers {
    ztc = {
      source  = "zscaler/ztc"
      version = "~> 0.1.9"
    }
  }
}
