packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "db_password" {
  type    = string
  default = ""
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_name" {
  type    = string
  default = ""
}

variable "project_id" {
  type    = string
  default = "csye-dev-453603"
}

variable "zone" {
  type    = string
  default = "us-east1-c"
}

variable "source_image_family" {
  type    = string
  default = "ubuntu-2204-lts-amd64"
}

variable "machine_type" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ami_name" {
  type    = string
  default = "ami_name"
}

variable "source_ami_owner" {
  type    = string
  default = "099720109477"
}

variable "source_ami" {
  type    = string
  default = "ami-04b4f1a9cf54c11d0"
}

variable "db_host" {
  type    = string
  default = "host"
}

source "googlecompute" "ubuntu" {
  project_id              = var.project_id
  zone                    = var.zone
  source_image_family     = var.source_image_family
  source_image_project_id = ["ubuntu-os-cloud"]
  ssh_username            = var.ssh_username
  machine_type            = var.machine_type
  image_name              = "csye6225-webapp-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  image_description       = "Custom image for CSYE6225 webapp"
  image_family            = "csye6225-webapp"
  image_storage_locations = ["us"]
}

build {
  sources = ["source.googlecompute.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y ca-certificates curl gnupg",
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "sudo apt-get install -y postgresql postgresql-contrib",
      "sudo systemctl enable postgresql",
      "sudo systemctl start postgresql",
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash",
      "export NVM_DIR=\"$HOME/.nvm\"",
      "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"",
      "PG_VERSION=$(psql -V | awk '{print $3}' | cut -d. -f1)",

      "if [ -d \"/etc/postgresql/$PG_VERSION/main\" ]; then",
      "echo 'local   all   postgres                                trust' | sudo tee /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      "echo 'host    all   all        127.0.0.1/32                md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      "echo 'host    all   all        ::1/128                     md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      "echo 'host    all   all        127.0.0.1/32    md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      "echo 'host    all   all        ::1/128         md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      "echo 'host    all             all             127.0.0.1/32            md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      "echo 'host    all             all             ::1/128                 md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      "echo 'host    all             all             0.0.0.0/0               md5' | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf",
      "sudo sed -i \"s/#listen_addresses = 'localhost'/listen_addresses = '*' /g\" /etc/postgresql/$PG_VERSION/main/postgresql.conf",
      "sudo systemctl restart postgresql",
      "else",
      "  echo 'Error: PostgreSQL directory not found. Installation might have failed.'",
      "  exit 1",
      "fi",
      "nvm install 18",
      # REMOVED "nvm use 18" to avoid interactive shell dependency
      "npm install -g pm2",

      # FIXED QUOTES for CREATE USER and ROLE
      "sudo -u postgres psql -tc \"SELECT 1 FROM pg_roles WHERE rolname = 'csye6225'\" | grep -q 1 || sudo -u postgres psql -c \"CREATE USER csye6225 WITH PASSWORD 'csye6225';\"",
      "sudo -u postgres psql -c \"ALTER ROLE csye6225 WITH SUPERUSER CREATEDB CREATEROLE LOGIN;\"",

      "sudo -u postgres bash -c \"PGPASSWORD=${var.db_password} psql -U postgres -c \\\"ALTER USER postgres WITH PASSWORD '${var.db_password}';\\\"\"",
      "sudo -u postgres psql -tc \"SELECT 1 FROM pg_database WHERE datname='${var.db_name}';\" | grep -q 1 || sudo -u postgres psql -c \"CREATE DATABASE ${var.db_name} WITH OWNER ${var.db_username};\"",
      "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${var.db_name} TO ${var.db_username};\""
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
      "export DB_HOST=\"${var.db_host}\"",
      "export DB_USER=\"${var.db_username}\"",
      "export DB_NAME=\"${var.db_name}\"",
      "export DB_PASSWORD=\"${var.db_password}\"",

      "echo 'Environment Variables Set:'",
      "echo 'DB_HOST='$DB_HOST",
      "echo 'DB_USER='$DB_USER",
      "echo 'DB_NAME='$DB_NAME",
      "echo 'DB_PASSWORD='$DB_PASSWORD",
      "sudo bash -c 'echo \"DB_NAME=${var.db_name}\nDB_USERNAME=postgres\nDB_PASSWORD=${var.db_password}\nDB_HOST=${var.db_host}\" > /tmp/webapp/.env'",

      "sudo chmod 644 /tmp/webapp/.env",
      "sudo chown csye6225:csye6225 /tmp/webapp/.env",

      "echo 'Contents of .env before moving:'",
      "cat /tmp/webapp/.env",

      "sudo mv /tmp/webapp /home/csye6225/",
      "sudo chown -R csye6225:csye6225 /home/csye6225/webapp",
      "sudo chmod -R 755 /home/csye6225/webapp",

      "echo 'Contents of .env after moving:'",
      "sudo -u csye6225 cat /home/csye6225/webapp/.env",
      "echo 'Waiting for PostgreSQL to be ready...'",
      "until pg_isready -h localhost -U postgres; do sleep 2; done",
      "echo 'PostgreSQL is ready!'",

      "sudo -u csye6225 bash -c 'cd /home/csye6225/webapp && npm install'",

      "echo 'Environment Variables before running tests:'",
      "sudo -u csye6225 bash -c 'env | grep DB_'",

      "sudo -u csye6225 bash -c 'cd /home/csye6225/webapp && npm test'"
    ]
  }

  provisioner "file" {
    source      = "./webapp.service"
    destination = "/tmp/webapp.service"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/webapp.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable webapp.service",
      "sudo systemctl start webapp.service"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*"
    ]
  }
}
