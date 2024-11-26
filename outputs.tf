output "sgroup" {
  value = aws_security_group.allow_ssh.id
}
output "Master_public_ip" {
  value = aws_instance.Master[*].public_ip
}

#output "private_key_pem" {
#  value     = tls_private_key.key_pair.private_key_pem
# sensitive = true  # Marking the output as sensitive
#}
output "public" {
  value = aws_subnet.public[*].id

}