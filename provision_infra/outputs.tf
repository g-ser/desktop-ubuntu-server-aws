output "instance_id_docker_host" {
  description = "EC2 instance ID of docker host"
  value       = aws_instance.docker_host.id
}

output "public_dns_docker_host" {
  description = "Public DNS name assigned to the docker host instance"
  value       = aws_instance.docker_host.public_dns
}

output "public_ip_docker_host" {
  description = "Public IP address of the docker host"
  value       = aws_instance.docker_host.public_ip
}

