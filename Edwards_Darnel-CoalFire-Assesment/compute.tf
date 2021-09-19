

resource "aws_instance" "RHEL" {
  ami                         = var.AMI
  instance_type               = var.SIZE
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.PublicSubnet2.id
  key_name                    = var.SSH_KEY
  vpc_security_group_ids      = [aws_security_group.RHEL_EC2.id]
  root_block_device {
    volume_size = 20
  }

  tags = {
    Name   = "RHEL_Ec2"
    Subnet = "Subnet 2"
  }
}
#Key for Ec2 Instance 
# resource "tls_private_key" "Private_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }


resource "aws_key_pair" "Redhat_Ec2_key" {
  key_name   = var.SSH_KEY
  public_key = file(var.generated_Pubkey-location)
}

# data "aws_ami" "RHEL" {
#   most_recent = true
#   owners      = ["aws-marketplace"]

#   filter {
#     name   = "name"
#     values = ["Hardened Redhat 7*"]
#   }

# }




