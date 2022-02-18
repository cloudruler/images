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
    subscription        = "2fb80bcc-8430-4b66-868b-8253e48a8317" #var.subscription_id
    resource_group      = "rg-images" #var.shared_gallery_resource_group
    gallery_name        = "cloudruler" #var.shared_gallery_name
    image_name          = var.image_name
    image_version       = var.image_version
    replication_regions = [ "South Central US"]
    #storage_account_type = "Standard_LRS"
  }
  location        = "South Central US"
  vm_size         = "Standard_DS2_v2"
  os_type         = "Linux"
  image_publisher = "canonical"
  image_offer     = "0001-com-ubuntu-server-impish"
  image_sku       = "21_10-gen2"
  image_version   = "latest"
  #ssh_username                      = var.ssh_user
  #ssh_password                      = var.ssh_pass
  #ssh_pty                           = "true"
}

build {
  sources = ["source.azure-arm.ubuntu"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
    skip_clean     = true
  }
}