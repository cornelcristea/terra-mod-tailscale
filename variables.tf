variable "tailscale_acls" {
  description = "Tailscale tailnet policy to manage."
  type = map(object({
    acl                        = optional(string)
    overwrite_existing_content = optional(bool)
    reset_acl_on_destroy       = optional(bool)
  }))
  default = {}
}

variable "tailscale_auth_keys" {
  description = "A list of Tailscale auth keys to manage."
  type = map(object({
    description         = optional(string)
    ephemeral           = optional(bool)
    expiry              = optional(number)
    preauthorized       = optional(bool)
    recreate_if_invalid = optional(string)
    reusable            = optional(bool)
    tags                = optional(list(string))
  }))
  default = {}
}

variable "tailscale_dns_configurations" {
  description = "Tailscale DNS configurations to manage."
  type = map(object({
    magic_dns = optional(bool)
    nameservers = optional(list(object({
      address            = optional(string)
      use_with_exit_node = optional(bool)
    })))
    override_local_dns = optional(bool)
    search_paths       = optional(list(string))
    split_dns = optional(map(list(object({
      address            = optional(string)
      use_with_exit_node = optional(bool)
    }))))
  }))
  default = {}
}

variable "tailscale_tailnet_settings" {
  description = "Tailnet settings to manage."
  type = map(object({
    acls_external_link                          = optional(string)
    acls_externally_managed_on                  = optional(bool)
    devices_approval_on                         = optional(bool)
    devices_auto_updates_on                     = optional(bool)
    devices_key_duration_days                   = optional(number)
    https_enabled                               = optional(bool)
    posture_identity_collection_on              = optional(bool)
    users_approval_on                           = optional(bool)
    users_role_allowed_to_join_external_tailnet = optional(string)
  }))
  default = {}
}
