packer {
  required_plugins {
    azure = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

source "azure-arm" "ubuntu" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  managed_image_resource_group_name = var.resource_group
  managed_image_name                = var.image_name
  shared_image_gallery_destination {
    subscription        = var.subscription_id
    resource_group      = var.shared_gallery_resource_group
    gallery_name        = var.shared_gallery_name
    image_name          = var.image_name
    image_version       = var.image_version
    replication_regions = [ "South Central US"]
  }
  location        = "South Central US"
  vm_size         = "Standard_DS2_v2"
  os_type         = "Linux"
  image_publisher = "canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts-gen2"
  image_version   = "latest"
  user_data_file  = "resources/cloud-config.yaml"
}

build {
  sources = ["source.azure-arm.ubuntu"]

  provisioner "shell" {
    environment_vars = [
      "CRIO_OS=xUbuntu_20.04",
      "CRIO_VER=1.23"
    ]
    #execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      #Deprovisioning step
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
    skip_clean     = true
  }
}
