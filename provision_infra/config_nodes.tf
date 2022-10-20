data "cloudinit_config" "ubuntu_server" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.local_file.ssm_agent.content
  }

}

# script that installs ssm agent

data "local_file" "ssm_agent" {
  filename = "${path.module}/scripts/ssm-agent-install.sh"
}
