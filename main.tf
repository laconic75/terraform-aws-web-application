terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.22.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "base_os" {
  most_recent = true

  filter {
    name   = "ami-name"
    values = var.ami_name_filter
  }

  filter {
    name   = "virtualization-type"
    values = var.ami_virtualization_type_filter
  }

  filter {
    name   = "architecture"
    values = var.ami_architecture_filter
  }

  owners = var.ami_owners_filter
}

data "aws_security_group" "web_application_sg" {
  name = "frontend_web_application"
  vpc  = var.vpc
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.base_os.id
  availability_zone           = var.availability_zone
  associate_public_ip_address = var.has_public_ip
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = var.iam_instance_profile
  instance_type               = var.instance_type
  private_ip                  = var.private_ip
  subnet_id                   = var.subnet_id
  user_data                   = var.user_data
  vpc_security_group_ids      = concat([data.aws_security_group.web_application_sg.id], var.additional_security_groups)

  tags = merge(var.standard_tags, var.application_tags)

  root_block_device = {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = var.root_iops
    delete_on_termination = var.root_delete_on_terminitaion
    encrypted             = var.encrypted
    kms_key_id            = var.kms_key_id
  }
}

resource "aws_volume" "data_volume" {
  availability_zone = var.availability_zone
  encrypted         = var.encrypted
  kms_key_id        = var.kms_key_id
  iops              = var.ebs_iops
  size              = var.ebs_size
  snapshot_id       = var.ebs_snapshot_id
  type              = var.ebs_type

  tags = merge(var.standard_tags, var.application_tags)
}  

resource "aws_volume_attachment" "ebs_att" {
  device_name = var.ebs_device_name # "/dev/sdg"
  volume_id   = aws_ebs_volume.data_volume.id
  instance_id = aws_instance.web.id
}
