output "instance_id_ubuntu_server" {
  description = "EC2 instance ID of docker host"
  value       = aws_instance.ubuntu_server.id
}
