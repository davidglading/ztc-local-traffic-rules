provider "ztc" {
  client_id = var.ztc_client_id

  client_secret = var.ztc_private_key != null && var.ztc_private_key != "" ? null : var.ztc_client_secret
  private_key   = var.ztc_private_key != null && var.ztc_private_key != "" ? var.ztc_private_key : null

  vanity_domain = var.ztc_vanity_domain
  ztc_cloud     = var.ztc_cloud

  use_legacy_client = var.use_legacy_client
  username          = var.use_legacy_client ? var.ztc_username : null
  password          = var.use_legacy_client ? var.ztc_password : null
  api_key           = var.use_legacy_client ? var.ztc_api_key : null
  zscaler_cloud     = var.use_legacy_client ? var.zscaler_cloud : null
}
