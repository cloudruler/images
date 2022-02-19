variable "tenant_id" {
  type    = string
  default = "${env("ARM_TENANT_ID")}"
}

variable "subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "client_id" {
  type    = string
  default = "${env("ARM_CLIENT_ID")}"
}

variable "client_secret" {
  type    = string
  default = "${env("ARM_CLIENT_SECRET")}"
}

variable "resource_group" {
  type = string
}

variable "image_name" {
  type = string
}

variable "image_version" {
  type = string
}

variable "shared_gallery_resource_group" {
  type = string
}

variable "shared_gallery_name" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "ssh_pass" {
  type = string
}
