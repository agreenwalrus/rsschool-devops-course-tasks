output "nat_sg_id" {
  value = aws_security_group.nat.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "ssh_from_bastion_sg_id" {
  value = aws_security_group.ssh_from_bastion.id
}

output "web_sg_id" {
  value = aws_security_group.web.id
}

output "inter_subnet_sg_id" {
  value = aws_security_group.inter_subnet.id
}
