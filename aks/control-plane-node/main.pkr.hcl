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
      #Use the modprobe command to load the overlay and the br_netfilter modules
      "modprobe overlay",
      "modprobe br_netfilter",
      #Apply the /etc/sysctl.d/k8s.conf config file to enable IP forwarding and netfilter settings across reboots
      "sysctl --system",
      #Add a new repository for the cri-o software
      "echo \"deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VER/$CRIO_OS/ /\" | tee -a /etc/apt/sources.list.d/cri-0.list",
      #Add the package key for the cri-o software
      "curl -L http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VER/$CRIO_OS/Release.key | apt-key add -",
      #Add the repository for libcontainer information
      "echo \"deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$CRIO_OS/ /\" | tee -a /etc/apt/sources.list.d/libcontainers.list",
      #Add the package key for libcontainer information
      "curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$CRIO_OS/Release.key | apt-key add -",
      #Install cri-io and runc
      "apt-get install -y cri-o cri-o-runc",
      #Enable cr-io
      "systemctl daemon-reload",
      "systemctl enable crio",
      "systemctl start crio",
      #Ensure cr-io is running
      "systemctl status crio",
      #Add the Kubernetes apt repository
      "echo \"deb https://apt.kubernetes.io/ kubernetes-xenial main\" | tee -a /etc/apt/sources.list.d/kubernetes.list",
      #Download the Google Cloud public signing key
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -",
      "apt-get install -y kubeadm=1.21.1-00 kubelet=1.21.1-00 kubectl=1.21.1-00",
      #Don't let these start yet
      "apt-mark hold kubelet kubeadm kubectl",
      #- [ apt-mark, hold, kubelet, kubeadm, kubectl ]
      #Deprovisioning step
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
    skip_clean     = true
  }
}
