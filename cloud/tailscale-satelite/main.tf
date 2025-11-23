terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

variable "ssh_public_key" {}
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
  display_name = "Tailscale Network"

  dns_label      = "tailscale"
  cidr_blocks    = ["10.0.0.0/16"]
  compartment_id = var.oracle_ocid
}

resource "oci_core_internet_gateway" "tailscale_gateway" {
  display_name = "Tailscale Gateway"

  compartment_id = var.oracle_ocid
  vcn_id         = oci_core_vcn.tailscale_network.id
}

resource "oci_core_route_table" "tailscale_route_table" {
  display_name = "Tailscale Route Table"

  compartment_id = var.oracle_ocid
  vcn_id         = oci_core_vcn.tailscale_network.id

  route_rules {
    description = "Allow connection to/from anywhere on the internet"

    network_entity_id = oci_core_internet_gateway.tailscale_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "tailscale_security_list" {
  display_name = "Tailscale Security List"

  compartment_id = var.oracle_ocid
  vcn_id         = oci_core_vcn.tailscale_network.id

  ingress_security_rules {
    description = "Allow UDP 41641 for Tailscale"
    protocol    = 17 # UDP
    source      = "0.0.0.0/0"
    stateless   = true
    udp_options {
      min = 41641
      max = 41641
    }
  }
}

resource "oci_core_security_list" "ssh_security_list" {
  display_name = "SSH Security List"

  compartment_id = var.oracle_ocid
  vcn_id         = oci_core_vcn.tailscale_network.id

  ingress_security_rules {
    description = "Allow TCP 22 for SSH"
    protocol    = 6 # TCP
    source      = "0.0.0.0/0"
    stateless   = true
    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_subnet" "tailscale_subnet" {
  display_name = "Tailscale Subnet"

  compartment_id = var.oracle_ocid
  vcn_id         = oci_core_vcn.tailscale_network.id
  cidr_block     = "10.0.1.0/24"
  route_table_id = oci_core_route_table.tailscale_route_table.id

  security_list_ids = [
    oci_core_security_list.tailscale_security_list.id,
    oci_core_security_list.ssh_security_list.id
  ]
}

resource "oci_core_instance" "tailscale_instance" {
  display_name = "Tailscale Node"

  availability_domain = var.oracle_availability_domain
  compartment_id      = var.oracle_ocid
  shape               = "VM.Standard.E2.1.Micro"

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # user_data           = base64encode(templatefile("tailscale.tftpl", { tailscale_auth_key = var.tailscale_auth_key }))
  }

  source_details {
    source_id   = var.oracle_image_id
    source_type = "image"
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.tailscale_subnet.id
  }

  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
  }
}
