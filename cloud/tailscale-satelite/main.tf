terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.56.0"
    }
  }
}

variable "hcloud_token" {
  sensitive = true
}

variable "tailscale_hetzner_api_key" {
  sensitive = true
}

locals {
  username = "daniel"
  ssh_port = 2222
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsEU2nPJ3+uDSSPR6KmKbmtpj/HV1UUua9MbElruG1Z Daniels Mac 2024"
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_firewall" "tailscale-firewall" {
  name = "tailscale-firewall"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = local.ssh_port
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = local.ssh_port
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "41641"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# Create a new server running debian
resource "hcloud_server" "tailscale-de" {
  name        = "tailscale-hetzner-de"
  image       = "ubuntu-24.04"
  server_type = "cx23"
  datacenter = "nbg1-dc3"
  user_data = templatefile(
    "cloud-init.yaml",
    {
        tailscale_hetzner_api_key = var.tailscale_hetzner_api_key,
        username = local.username,
        ssh_port = local.ssh_port,
        ssh_key = local.ssh_key,
    }
  )
  firewall_ids = [hcloud_firewall.tailscale-firewall.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
