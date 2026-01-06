variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "profile" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "db_password" {
  type    = string
  default = "password"
}

variable "db_username" {
  type    = string
  default = "name"
}

variable "db_name" {
  type    = string
  default = "name"
}

variable "project_id" {
  type    = string
  default = "project_id"
}

variable "zone" {
  type    = string
  default = "zone"
}

variable "source_image_family" {
  type    = string
  default = "image"
}

variable "machine_type" {
  type    = string
  default = "machine"
}

variable "ssh_username" {
  type    = string
  default = "username"
}

variable "ami_name" {
  type    = string
  default = "ami_name"
}

variable "source_ami_owner" {
  type    = string
  default = "099720109477"
}

variable "gcp_service_account_email" {
  type    = string
  default = "gcp_service_account_email"
}

variable "dev_aws_account_id" {
  type    = string
  default = "acoount_id"
}

variable "source_ami" {
  type    = string
  default = "ami-04b4f1a9cf54c11d0"
}

variable "db_host" {
  type    = string
  default = "host"
}
