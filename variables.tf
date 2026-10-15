variable "ztc_client_id" {
  description = "ZTC API client ID. Prefer TF_VAR_ztc_client_id over terraform.tfvars."
  type        = string
  default     = null
  sensitive   = true
}

variable "ztc_client_secret" {
  description = "ZTC API client secret. Prefer TF_VAR_ztc_client_secret over terraform.tfvars."
  type        = string
  default     = null
  sensitive   = true
}

variable "ztc_private_key" {
  description = "ZTC API private key, used instead of ztc_client_secret when supplied."
  type        = string
  default     = null
  sensitive   = true
}

variable "ztc_vanity_domain" {
  description = "Zscaler vanity domain."
  type        = string
  default     = null
}

variable "ztc_cloud" {
  description = "ZTC cloud identifier, if required by the tenant."
  type        = string
  default     = null
}

variable "use_legacy_client" {
  description = "Set true to use legacy ZTC authentication."
  type        = bool
  default     = false
}

variable "ztc_username" {
  description = "Legacy-mode ZTC username."
  type        = string
  default     = null
  sensitive   = true
}

variable "ztc_password" {
  description = "Legacy-mode ZTC password."
  type        = string
  default     = null
  sensitive   = true
}

variable "ztc_api_key" {
  description = "Legacy-mode ZTC API key."
  type        = string
  default     = null
  sensitive   = true
}

variable "zscaler_cloud" {
  description = "Legacy-mode Zscaler cloud name."
  type        = string
  default     = null
}

variable "local_traffic_rules" {
  description = "LOCAL_SWITCH traffic-forwarding rules keyed by a Terraform identifier."
  type = map(object({
    name                  = string
    location_name         = string
    source_cidrs          = set(string)
    destination_cidrs     = set(string)
    network_service_ids   = optional(list(number), [])
    network_service_names = optional(list(string), [])
    description           = optional(string, null)
    order                 = optional(number, 1)
    rank                  = optional(number, 7)
    enabled               = optional(bool, true)
  }))
  default = {}

  validation {
    condition     = alltrue([for rule in values(var.local_traffic_rules) : length(rule.name) <= 63])
    error_message = "Each local_traffic_rules name must be 63 characters or fewer."
  }

  validation {
    condition = alltrue([
      for rule in values(var.local_traffic_rules) :
      length(rule.network_service_ids) > 0 || length(rule.network_service_names) > 0
    ])
    error_message = "Each rule must set network_service_ids or network_service_names."
  }
}

variable "enable_policy_activation" {
  description = "Submit Zscaler activation after managed rules change. Activation may include unrelated pending tenant changes."
  type        = bool
  default     = false
}
