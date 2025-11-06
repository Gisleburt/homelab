terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

variable "tailscale_auth_key" {}
variable "oracle_ocid" {}
variable "oracle_availability_domain" {}
variable "oracle_image_id" {}

provider "oci" {
  region              = "eu-zurich-1"
  auth                = "SecurityToken"
  config_file_profile = "tailscale-ch"
}

resource "oci_core_vcn" "tailscale_network" {
  dns_label      = "tailscale"
  cidr_blocks    = ["10.0.0.0/16"]
  compartment_id = var.oracle_ocid
  display_name   = "Tailscale Network"
}

resource "oci_core_subnet" "tailscale_subnet" {
  compartment_id = var.oracle_ocid
  vcn_id = oci_core_vcn.tailscale_network.id
  cidr_block    = "10.0.0.0/16"
}

resource "oci_core_instance" "tailscale_instance" {
  display_name = "Tailscale Node"
  
  availability_domain = var.oracle_availability_domain
  compartment_id = var.oracle_ocid
  shape = "VM.Standard.E2.1.Micro"

  metadata = {
    user_data = base64encode(templatefile("tailscale.tftpl", { tailscale_auth_key = var.tailscale_auth_key }))
  }

  source_details {
    source_id = var.oracle_image_id
    source_type = "image"
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.tailscale_subnet.id
  }

  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled = true
    is_monitoring_disabled = true
  }
}
