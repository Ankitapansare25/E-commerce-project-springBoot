#!/bin/bash
yum update -y
yum install -y java-17-amazon-corretto git

cd /home/ec2-user
git clone https://github.com/Ankitapansare25/E-commerce-project-springBoot.git

cd repo
chmod +x mvnw

# Create service
cat <<EOF > /etc/systemd/system/springboot.service
[Unit]
Description=Spring Boot App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/repo
ExecStart=/home/ec2-user/repo/mvnw spring-boot:run
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable springboot
systemctl start springboot