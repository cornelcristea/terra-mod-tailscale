# https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/null_resource
resource "null_resource" "auth_key" {
  for_each = var.tailscale_auth_keys

  # Save tailnet key in a file to be used by other tools (e.g. Ansible)
  provisioner "local-exec" {
    command = "echo ${tailscale_tailnet_key.this[each.key]}: ${tailscale_tailnet_key.this[each.key].key} >> tailscale_auth_keys.txt"
  }
}

# https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/acl
resource "tailscale_acl" "this" {
  for_each = var.tailscale_acls

  acl                        = each.value.acl
  overwrite_existing_content = each.value.overwrite_existing_content
  reset_acl_on_destroy       = each.value.reset_acl_on_destroy
}

# https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/dns_configuration
resource "tailscale_dns_configuration" "this" {
  for_each = var.tailscale_dns_configurations

  dynamic "nameservers" {
    for_each = each.value.nameservers

    content {
      address            = nameservers.value.address
      use_with_exit_node = nameservers.value.use_with_exit_node
    }
  }

  dynamic "split_dns" {
    for_each = each.value.split_dns

    content {
      domain = split_dns.key

      dynamic "nameservers" {
        for_each = split_dns.value

        content {
          address            = nameservers.value.address
          use_with_exit_node = nameservers.value.use_with_exit_node
        }
      }
    }
  }

  magic_dns          = each.value.magic_dns
  override_local_dns = each.value.override_local_dns
  search_paths       = each.value.search_paths
}

# https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/tailnet_key
resource "tailscale_tailnet_key" "this" {
  for_each = var.tailscale_auth_keys

  description         = each.value.description
  ephemeral           = each.value.ephemeral
  expiry              = each.value.expiry
  preauthorized       = each.value.preauthorized
  recreate_if_invalid = each.value.recreate_if_invalid
  reusable            = each.value.reusable
  tags                = each.value.tags
}

# https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/tailnet_settings
resource "tailscale_tailnet_settings" "this" {
  for_each = var.tailscale_tailnet_settings

  acls_external_link                          = each.value.acls_external_link
  acls_externally_managed_on                  = each.value.acls_externally_managed_on
  devices_approval_on                         = each.value.devices_approval_on
  devices_auto_updates_on                     = each.value.devices_auto_updates_on
  devices_key_duration_days                   = each.value.devices_key_duration_days
  https_enabled                               = each.value.https_enabled
  posture_identity_collection_on              = each.value.posture_identity_collection_on
  users_approval_on                           = each.value.users_approval_on
  users_role_allowed_to_join_external_tailnet = each.value.users_role_allowed_to_join_external_tailnet
}
