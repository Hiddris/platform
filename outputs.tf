output "instance_id"{
    description = "ID of EC2 instance"
    value = aws_instance.app_server.id
}

output "instanace_public_id" {
  description = "Public IP address of the EC2 instance"
  value = aws_instance.app_server.public_ip
}