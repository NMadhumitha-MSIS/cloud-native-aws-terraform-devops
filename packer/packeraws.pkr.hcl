packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = ""
}
variable "profile" {
  type    = string
  default = ""
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "db_password" {
  type    = string
  default = ""
}
variable "db_username" {
  type    = string
  default = ""
}
variable "db_name" {
  type    = string
  default = ""
}
variable "source_image_family" {
  type    = string
  default = ""
}
variable "machine_type" {
  type    = string
  default = ""
}
variable "ssh_username" {
  type    = string
  default = ""
}
variable "ami_name" {
  type    = string
  default = ""
}
variable "source_ami_owner" {
  type    = string
  default = ""
}
variable "dev_aws_account_id" {
  type    = string
  default = ""
}
variable "source_ami" {
  type    = string
  default = "ami-0fc5d935ebf8bc3bc"
}
variable "db_host" {
  type    = string
  default = ""
}


source "amazon-ebs" "ubuntu" {
  profile       = var.profile
  ami_name      = "csye6225-nodejs-app-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami    = var.source_ami
  ssh_username  = "ubuntu"

  tags = {
    Name = "csye6225-nodejs-app"
  }
  run_tags = {
    KeepAlive = "true"
  }
  force_deregister      = false
  force_delete_snapshot = false
  ami_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }
  # ami_groups = ["${var.dev_aws_account_id}"]
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo apt-get update --allow-insecure-repositories || sudo apt-get update --allow-unauthenticated",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl unzip ca-certificates curl gnupg",
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      # "sudo apt-get install -y postgresql postgresql-contrib",
      # "sudo systemctl enable postgresql",
      # "sudo systemctl start postgresql",
      # "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash",
      # "export NVM_DIR=\"$HOME/.nvm\"",
      # "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"",
      # "PG_VERSION=$(psql -V | awk '{print $3}' | cut -d. -f1)",

      # Verify the directory exists before modifying configuration
      # "if [ -d \"/etc/postgresql/$PG_VERSION/main\" ]; then",
      # "echo 'local   all   postgres                                trust' | sudo tee /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      # "echo 'host    all   all        127.0.0.1/32                md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      # "echo 'host    all   all        ::1/128                     md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",

      # "echo 'host    all   all        127.0.0.1/32    md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      # "echo 'host    all   all        ::1/128         md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",

      # "echo 'host    all             all             127.0.0.1/32            md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      # "echo 'host    all             all             ::1/128                 md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      # "echo 'host    all             all             0.0.0.0/0               md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",

      # "sudo sed -i \"s/#listen_addresses = 'localhost'/listen_addresses = '*' /g\" /etc/postgresql/$PG_VERSION/main/postgresql.conf",

      # "sudo systemctl stop postgresql",
      # "sudo systemctl start postgresql",
      # "sudo systemctl stop postgresql",
      # "sudo systemctl start postgresql",
      # "sudo systemctl restart postgresql",


      # "else",
      # "  echo 'Error: PostgreSQL directory not found. Installation might have failed.'",
      # "  exit 1",
      # "fi",
      # "nvm install 18",
      # "nvm use 18",
      "sudo npm install -g pm2",
      # Set up PostgreSQL user and database
      # "sudo -u postgres bash -c \"PGPASSWORD=${var.db_password} psql -U postgres -c \\\"ALTER USER postgres WITH PASSWORD '${var.db_password}';\\\"\"",
      # # Ensure the database exists
      # "sudo -u postgres psql -tc \"SELECT 1 FROM pg_database WHERE datname='${var.db_name}';\" | grep -q 1 || sudo -u postgres psql -c \"CREATE DATABASE ${var.db_name} WITH OWNER ${var.db_username};\"",
      # "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${var.db_name} TO ${var.db_username};\""
    ]
  }
  provisioner "shell" {
    inline = [
      "if ! getent group csye6225 > /dev/null 2>&1; then sudo groupadd csye6225; fi",
      "if ! id -u csye6225 > /dev/null 2>&1; then sudo useradd -m -s /usr/sbin/nologin csye6225 -g csye6225; else sudo usermod -s /usr/sbin/nologin csye6225; fi",
      "sudo usermod -aG csye6225 csye6225"
    ]
  }

  provisioner "file" {
    source      = "../webapp"
    destination = "/tmp/webapp"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/webapp /home/csye6225/webapp",
      "sudo chown -R csye6225:csye6225 /home/csye6225/webapp"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get install -y unzip",
      "sudo chown -R csye6225:csye6225 /home/csye6225/webapp",
      "sudo -u csye6225 bash -c 'cd /home/csye6225/webapp && npm install'",
      "echo 'export NVM_DIR=\"$HOME/.nvm\"' >> ~/.bashrc",
      "echo '[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"' >> ~/.bashrc"
    ]
  }

  provisioner "file" {
    source      = "webapp.service"
    destination = "/tmp/webapp.service"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/webapp.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable webapp.service"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo Installing CloudWatch Agent from AWS...",
      "cd /tmp",
      "wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb",
      "sudo dpkg -i -E ./amazon-cloudwatch-agent.deb",
      "echo Done installing CloudWatch Agent."
    ]
  }

  provisioner "file" {
    source      = "amazon-cloudwatch-agent.json"
    destination = "/tmp/amazon-cloudwatch-agent.json"
  }

  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "cd /tmp",
      "sudo mv /tmp/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
      "sudo chown root:root /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
      "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s",
      "sudo systemctl enable amazon-cloudwatch-agent"
    ]
  }
}
