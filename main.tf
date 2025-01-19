provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "ngnix-server" {
    ami           = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"

    #User data es un script que se ejecuta al iniciar, en este caso se instala ngnix
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install -y nginx
                sudo systemctl enable nginx
                sudo systemctl start nginx
                EOF
    
    key_name = aws_key_pair.ngnix-server-ssh.key_name

    vpc_security_group_ids = [aws_security_group.ngnix-server-sg.id] 
}


# Crear un key pair para conectarse a la instancia
resource "aws_key_pair" "ngnix-server-ssh" {
  key_name = "ngnix-server-ssh"
  public_key = file("ngnix-server.key.pub")
}

resource "aws_security_group" "ngnix-server-sg" {
  name        = "ngnix-server-sg"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }   

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}
    