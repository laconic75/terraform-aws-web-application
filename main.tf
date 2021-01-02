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

locals {
  application_tags = merge(var.application_tags, { hostname: var.hostname })
  hostname_split   = split(".", var.hostname)
  dns_root         = join(".", slice(local.hostname_split, 1, length(local.hostname_split)))
}

data "aws_ami" "base_os" {
  most_recent = true

  filter {
    name   = "name"
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
  name    = "frontend_web_application"
  vpc_id  = var.vpc
}

data "aws_route53_zone" "public" {
  name = local.dns_root
  private_zone = false
}

resource "aws_route53_record" "public" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.hostname
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web.public_ip]
}

data "aws_route53_zone" "private" {
  name = local.dns_root
  private_zone = true
  vpc_id = var.vpc
}

resource "aws_route53_record" "web_server" {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = var.hostname
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web.private_ip]
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

  tags = merge(var.standard_tags, local.application_tags)

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = var.root_iops
    delete_on_termination = var.root_delete_on_terminitaion
    encrypted             = var.encrypted
    kms_key_id            = var.kms_key_id
  }
}

resource "aws_ebs_volume" "data_volume" {
  availability_zone = var.availability_zone
  encrypted         = var.encrypted
  kms_key_id        = var.kms_key_id
  iops              = var.ebs_iops
  size              = var.ebs_size
  snapshot_id       = var.ebs_snapshot_id
  type              = var.ebs_type

  tags = merge(var.standard_tags, local.application_tags)
}  

resource "aws_volume_attachment" "data_volume" {
  device_name = var.ebs_device_name # "/dev/sdg"
  volume_id   = aws_ebs_volume.data_volume.id
  instance_id = aws_instance.web.id
}
