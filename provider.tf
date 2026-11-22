terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.29.1"
    }
  }
  required_version = ">= 1.13"
}
