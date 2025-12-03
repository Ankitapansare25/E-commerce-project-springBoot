provider "aws" {
  region = "ap-south-1"
}

# VARIABLES

variable "db_username" {
    default = "admin"
}
variable "db_password" {
  sensitive = true
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
    default = "mumbai"
}

# SECURITY GROUP FOR EC2

resource "aws_security_group" "ec2_sg" {
  name = "ec2-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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


# SECURITY GROUP FOR RDS

resource "aws_security_group" "rds_sg" {
  name = "rds-sg"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}



# EC2 INSTANCE FOR SPRING BOOT APP

resource "aws_instance" "app_server" {
  ami           = "ami-0d176f79571d18a8f"   # Amazon Linux 2
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups = [aws_security_group.ec2_sg.name]
  user_data       = file("user-data.sh")

  tags = {
    Name = "SpringBoot-EC2"
  }
}


# RDS INSTANCE

resource "aws_db_instance" "app_db" {
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = "springdb"

  username             = var.db_username
  password             = var.db_password

  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
}



# OUTPUTS
output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.app_db.endpoint
}