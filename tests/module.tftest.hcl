mock_provider "tailscale" {}
mock_provider "null" {}

run "tailscale_acls" {
  command = plan

  variables {
    tailscale_acls = {
      test = {
        acl = jsonencode({
          acls = [
            {
              action = "accept"
              src    = ["*"]
              dst    = ["*:*"]
            }
          ]
        })
        overwrite_existing_content = true
        reset_acl_on_destroy       = true
      }
    }
  }

  assert {
    condition     = jsondecode(tailscale_acl.this["test"].acl).acls[0].dst[0] == "*:*"
    error_message = "The ACL policy should be passed through to the Tailscale ACL resource."
  }

  assert {
    condition = (
      tailscale_acl.this["test"].overwrite_existing_content &&
      tailscale_acl.this["test"].reset_acl_on_destroy
    )
    error_message = "ACL resource options should be passed through."
  }
}

run "tailscale_auth_keys" {
  command = plan

  variables {
    tailscale_acls = {
      test = {
        acl = jsonencode({ acls = [] })
      }
    }

    tailscale_auth_keys = {
      automation = {
        description   = "test key"
        ephemeral     = false
        expiry        = 3600
        preauthorized = true
        reusable      = true
        tags          = ["tag:terraform"]
      }
    }
  }

  assert {
    condition = (
      tailscale_tailnet_key.this["automation"].description == "test key" &&
      tailscale_tailnet_key.this["automation"].tags == toset(["tag:terraform"])
    )
    error_message = "Auth key configuration should be passed through."
  }

  assert {
    condition     = toset(keys(null_resource.auth_key)) == toset(["automation"])
    error_message = "The auth key file helper should be planned for each configured auth key."
  }
}

run "tailscale_dns_configurations" {
  command = plan

  variables {
    tailscale_acls = {
      test = {
        acl = jsonencode({ acls = [] })
      }
    }

    tailscale_dns_configurations = {
      home = {
        magic_dns          = true
        override_local_dns = true
        search_paths       = ["homelab.internal"]
        nameservers = [
          {
            address            = "192.168.1.1"
            use_with_exit_node = false
          }
        ]
        split_dns = {
          "homelab.internal" = [
            {
              address            = "192.168.1.1"
              use_with_exit_node = false
            }
          ]
        }
      }
    }
  }

  assert {
    condition = (
      tailscale_dns_configuration.this["home"].magic_dns &&
      tailscale_dns_configuration.this["home"].nameservers[0].address == "192.168.1.1" &&
      tailscale_dns_configuration.this["home"].split_dns[0].domain == "homelab.internal"
    )
    error_message = "DNS settings, nameservers, and split DNS should be configured."
  }
}

run "tailscale_tailnet_settings" {
  command = plan

  variables {
    tailscale_acls = {
      test = {
        acl = jsonencode({ acls = [] })
      }
    }

    tailscale_tailnet_settings = {
      test = {
        devices_approval_on       = true
        devices_key_duration_days = 90
        https_enabled             = true
        users_approval_on         = true
      }
    }
  }

  assert {
    condition = (
      tailscale_tailnet_settings.this["test"].devices_approval_on &&
      tailscale_tailnet_settings.this["test"].https_enabled &&
      tailscale_tailnet_settings.this["test"].users_approval_on &&
      tailscale_tailnet_settings.this["test"].devices_key_duration_days == 90
    )
    error_message = "Tailnet settings should be applied as one resource configuration."
  }
}
