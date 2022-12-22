
output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}


