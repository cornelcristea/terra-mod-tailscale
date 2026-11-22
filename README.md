# terra-mod-tailscale

This module manages a Tailscale tailnet policy, auth keys, DNS configuration,
and tailnet settings. Configure the Tailscale provider in the calling
configuration.

## Usage

```hcl
module "tailscale" {
  source = "git::https://github.com/cornelcristea/terra-mod-tailscale.git?ref=main"

  tailscale_acls = {
    default = {
      acl = jsonencode({
        tagOwners = {
          "tag:terraform" = ["autogroup:admin"]
        }
        autoApprovers = {
          routes = {
            "192.168.1.0/24" = ["tag:terraform"]
          }
        }
        grants = [
          {
            src = ["*"]
            dst = ["*"]
            ip  = ["*"]
          }
        ]
      })
      overwrite_existing_content = true
      reset_acl_on_destroy       = true
    }
  }

  tailscale_auth_keys = {
    automation = {
      description   = "Managed by Terraform"
      reusable      = true
      preauthorized = true
      tags          = ["tag:terraform"]
    }
  }

  tailscale_dns_configurations = {
    home = {
      magic_dns    = true
      search_paths = ["example.internal"]
      nameservers = [
        {
          address = "192.168.1.1"
        }
      ]
    }
  }

  tailscale_tailnet_settings = {
    default = {
      devices_approval_on = true
      https_enabled       = true
    }
  }
}
```

Each value in `tailscale_acls` contains an `acl` string with a complete
Tailscale policy document. Use `jsonencode(...)` for an HCL object or pass
HuJSON text directly as a string. The policy can include supported sections
such as `acls`, `grants`, `tagOwners`, and `autoApprovers`.

All module inputs are maps keyed by a local identifier and default to empty
maps. Provide each ACL and tailnet settings configuration as an object in its
map.

## Inputs

| Name | Type | Description |
| --- | --- | --- |
| `tailscale_acls` | Map of objects | Tailnet policy strings and ACL resource options. |
| `tailscale_auth_keys` | Map of objects | Auth key configuration, keyed by a local identifier. |
| `tailscale_dns_configurations` | Map of objects | DNS settings keyed by a local identifier; supports nameservers and split DNS. |
| `tailscale_tailnet_settings` | Map of objects | Tailnet-wide settings keyed by a local identifier. |

Auth key details are also written by the module's local provisioner to
`tailscale_auth_keys.txt` in the working directory. Protect that file as a
secret.

## Tests

Run the module's OpenTofu tests from this directory:

```sh
source ./tests/test.sh
```