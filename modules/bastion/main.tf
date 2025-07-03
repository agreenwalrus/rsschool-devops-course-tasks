# EC2 instance Bastion
resource "aws_instance" "bastion" {
  ami                         = var.ami_id 
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  key_name                    = var.ec2_key_name
  source_dest_check           = false
  tags                        = { Name = "${var.vpc_name}-nat-bastion" }
}


