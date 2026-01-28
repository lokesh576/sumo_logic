data "aws_ami" "pacerpro_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "pacerpro_ec2_instance" {
  ami = data.aws_ami.pacerpro_ami.id
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = 0.0031
    }
  }
  instance_type = "t3.micro"
  tags = {
    Name = "${var.application_name}-demo-ec2"
  }
}