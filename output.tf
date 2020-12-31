output "instance_id" {
  value = aws_instance.web.id
}

output "volume_id" {
  value = aws_ebs_volume.data_volume.id
}

output "volume_device_name" {
 value = aws_volume_attachment.data_volume.device_name
}
