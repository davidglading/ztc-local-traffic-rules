output "local_traffic_rule_ids" {
  description = "Zscaler IDs of the managed LOCAL_SWITCH traffic-forwarding rules."
  value       = { for rule_key, rule in ztc_traffic_forwarding_rule.local_switch : rule_key => rule.rule_id }
}

output "final_activation_status" {
  description = "Activation status captured during apply when enable_policy_activation is true."
  value       = try(ztc_activation_status.final[0], null)
}
