################### AMI Selection
variable "ami_name_filter" {
  type = list(string)
  default = ["CentOS 8*"]
}

variable "ami_virtualization_type_filter" {
  type = list(string)
  default = ["hvm"]
}

variable "ami_architecture_filter" {
  type = list(string)
  default = ["x86_64"]
}

variable "ami_owners_filter" {
  type = list(string)
  default =  ["125523088429"] # Red Hat
}

###################  General
variable "availability_zone" {
  type = string
}

variable "ebs_optimized" {
  type = bool
  default = true
}

variable "instance_type" {
  type = string
  default = "m5.medium"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "user_data" {
  type = string
  default = null
}

###################  Networking
variable "private_ip" {
  type = string
  default = null
}

variable "subnet_id" {
  type = string
  default = null
}

###################  Security
variable "iam_instance_profile" {
  type = string
  default = null
}

variable "additional_security_groups" {
  type = list(string)
  default = null
}

variable "encrypted" {
  type = bool
  default = true
}

variable "kms_key_id" {
  type = string
  default = null
}

###################  Volumes
variable "root_delete_on_terminitaion" {
  type = bool
  default = true
}

variable "root_iops" {
  type = string
  default = null
}

variable "root_volume_size" {
  type = string
  default = null
}

variable "root_volume_type" {
  type = string
  default = "gp2"
}

variable "ebs_device_name" {
  type = string
  default = "/dev/sdg"
}

variable "ebs_iops" {
  type = string
  default = null
}

variable "ebs_size" {
  type = string
  default = null
}

variable "ebs_type" {
  type = string
  default = "gp2"
}

variable "ebs_snapshot_id" {
  type = string
  default = null
}

###################  Tags
variable "standard_tags" {
  type = map(string)
}

variable "application_tags" {
  type = map(string)
  default = null
}
