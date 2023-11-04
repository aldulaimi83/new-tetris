

resource "aws_vpc" "tetris_game_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "tetris_game_subnet" {
  vpc_id                  = aws_vpc.tetris_game_vpc.id
  cidr_block              = "10.0.0.0/24"  # Adjust the CIDR block for your subnet
  availability_zone       = "us-east-2a"  # Choose the desired availability zone
  map_public_ip_on_launch = true
}

resource "aws_security_group" "tetris_game_sg" {
  name        = "tetris-game-sg"
  description = "Security group for the Tetris game"

  vpc_id = aws_vpc.tetris_game_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_zone" "al_dulaimi_com" {
  name = "al-dulaimi.com"
}

resource "aws_route53_record" "al_dulaimi_com" {
  zone_id = aws_route53_zone.al_dulaimi_com.zone_id
  name    = "al-dulaimi.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.tetris_game_instance.public_ip]
}

resource "aws_instance" "tetris_game_instance" {
  ami           = "ami-0fa399d9c130ec923"  # Replace with the desired AMI ID
  instance_type = "t2.micro"  # Choose an appropriate instance type
  subnet_id     = "subnet-09ecbd4b5975fbbde"  # Specify the subnet ID you found or created

  tags = {
    Name = "tetris-game-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd

              # Configure and start the Apache web server
              systemctl start httpd
              systemctl enable httpd

              # Download and deploy the Tetris game code
              git clone https://github.com/yourusername/tetris-game.git /var/www/html

              # Additional configuration for your game (e.g., database setup, environment variables, etc.)
              # ...

              # Restart Apache to apply changes
              systemctl restart httpd
              EOF
}
