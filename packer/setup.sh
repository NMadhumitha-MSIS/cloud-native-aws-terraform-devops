#!/bin/bash

set -e  # Exit immediately if a command fails

echo "Starting setup..."

# Create group if it doesn't exist
if ! getent group csye6225 > /dev/null 2>&1; then
   sudo groupadd csye6225
fi

# Create user if it doesn't exist
if id "csye6225user" &>/dev/null; then
   echo "User 'csye6225user' already exists."
else
   sudo useradd -m -s /bin/bash -g csye6225 csye6225user
fi

# Install necessary packages
sudo apt update
sudo apt install -y postgresql nodejs unzip npm

# Ensure PostgreSQL is running
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Ensure target directory exists
sudo mkdir -p /opt/csye6225

# Check if the zip file exists
if [ -f "/tmp/ass-02/webapp.zip" ]; then
   sudo unzip -o /tmp/ass-02/webapp.zip -d /opt/csye6225
else
   echo "Error: /tmp/ass-02/webapp.zip not found!"
   exit 1
fi

# Update permissions of the folder and artifacts
sudo chown -R csye6225user:csye6225 /opt/csye6225
sudo chmod -R 750 /opt/csye6225

# Load environment variables
if [ -f /opt/csye6225/webapp/.env ]; then
   source /opt/csye6225/webapp/.env
else
   echo "Error: .env file not found!"
   exit 1
fi

# PostgreSQL Setup
sudo -u postgres psql <<EOF
DO \$\$ 
BEGIN 
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_USERNAME') THEN 
      CREATE USER $DB_USERNAME WITH PASSWORD '$DB_PASSWORD'; 
   END IF; 
END \$\$;
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USERNAME;
EOF

# Navigate to application directory
cd /opt/csye6225/webapp || { echo "Error: Webapp directory missing!"; exit 1; }

# Install and test Node.js application
npm install || { echo "Error: npm install failed!"; exit 1; }
npm test || { echo "Error: npm test failed!"; exit 1; }

echo "Setup completed successfully!"