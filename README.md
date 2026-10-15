# Zscaler Local Traffic Forwarding Rules

This Terraform project manages Zscaler Zero Trust Gateway `LOCAL_SWITCH`
traffic-forwarding rules only. It does not create the associated cloud native components.

Zscaler policies can be based on Workload Groups as well as CIDR blocks.
This project's current inputs configure rules using source and destination CIDR
blocks; using Workload Groups requires extending the rule configuration.

## Required Information

- Zscaler API credentials with permission to create and manage traffic-forwarding rules
- An existing Zscaler gateway location name for each rule
- A unique rule name of 63 characters or fewer
- Source and destination CIDR blocks
- Zscaler network service names, such as `HTTP` and `ICMP_ANY`, or their numeric IDs

The project uses the released `zscaler/ztc` provider from the Terraform Registry.
Terraform installs the provider automatically when you run `terraform init`.

## Authentication

Keep credentials out of `terraform.tfvars`. Export them in the shell that runs
Terraform:

```bash
export TF_VAR_ztc_client_id="YOUR_ZTC_CLIENT_ID"
export TF_VAR_ztc_client_secret="YOUR_ZTC_CLIENT_SECRET"
export TF_VAR_ztc_vanity_domain="YOUR_ZTC_VANITY_DOMAIN"
# export TF_VAR_ztc_cloud="YOUR_ZTC_CLOUD" # only if your tenant requires it
```

Private-key and legacy authentication are also supported; see the variables in
`variables.tf`.

## Configure Rules

Copy the example and replace every placeholder with tenant-specific values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Each entry in `local_traffic_rules` creates one `LOCAL_SWITCH` rule. Supply
`network_service_ids` when you already know the service IDs; otherwise supply
`network_service_names` and Terraform looks them up by name. Rule names must be
unique in the tenant and are limited to 63 characters by Zscaler.

## Apply

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Activation

Zscaler may require activation before the changed policy takes effect. To have
Terraform submit activation after its managed rules change, set this in
`terraform.tfvars`:

```hcl
enable_policy_activation = true
```

Activation is disabled by default because activation can also apply unrelated
pending changes in the tenant. Review the tenant's pending changes before
enabling it. Set `enable_policy_activation = false` to save rule changes without
activating them. When enabled, activation follows managed rule additions,
updates, and removals during `terraform apply`. A destroy removes
Terraform-managed rules but does not activate their deletion; run an activation
separately if required by your tenant.
