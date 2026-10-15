locals {
  network_service_lookups = {
    for lookup in flatten([
      for rule_key, rule in var.local_traffic_rules : length(rule.network_service_ids) == 0 ? [
        for service_name in rule.network_service_names : {
          key          = "${rule_key}:${service_name}"
          service_name = service_name
        }
      ] : []
    ]) : lookup.key => lookup
  }

  effective_network_service_ids = {
    for rule_key, rule in var.local_traffic_rules : rule_key => (
      length(rule.network_service_ids) > 0 ? rule.network_service_ids : [
        for service_name in rule.network_service_names :
        data.ztc_network_services.by_name["${rule_key}:${service_name}"].network_service_id
      ]
    )
  }
}

data "ztc_location_management" "by_rule" {
  for_each = var.local_traffic_rules
  name     = each.value.location_name
}

data "ztc_network_services" "by_name" {
  for_each = local.network_service_lookups
  name     = each.value.service_name
}

resource "ztc_traffic_forwarding_rule" "local_switch" {
  for_each = var.local_traffic_rules

  name           = each.value.name
  description    = each.value.description
  forward_method = "LOCAL_SWITCH"
  order          = each.value.order
  rank           = each.value.rank
  state          = each.value.enabled ? "ENABLED" : "DISABLED"
  type           = "EC_RDR"

  locations {
    id = [data.ztc_location_management.by_rule[each.key].location_id]
  }

  src_ips        = each.value.source_cidrs
  dest_addresses = each.value.destination_cidrs

  nw_services {
    id = local.effective_network_service_ids[each.key]
  }
}

# Activation is intentionally opt-in because it can apply unrelated pending tenant edits.
resource "terraform_data" "managed_rules" {
  count = var.enable_policy_activation ? 1 : 0

  input = {
    rule_ids = { for rule_key, rule in ztc_traffic_forwarding_rule.local_switch : rule_key => rule.rule_id }
  }
}

resource "ztc_activation_status" "final" {
  count = var.enable_policy_activation ? 1 : 0

  depends_on = [terraform_data.managed_rules]

  lifecycle {
    replace_triggered_by = [terraform_data.managed_rules[0]]
    ignore_changes = [
      org_edit_status,
      org_last_activate_status,
      admin_activate_status,
    ]
  }
}
