# source: https://www.keycloak.org/downloads
# 
#!/bin/bash

# Variables
DB_NAME="keycloak"
DB_USER="farooq"
DB_PASSWORD="farooq01@"
KEYCLOAK_PASSWORD="farooq001@"
KEYCLOAK_VERSION="25.0.1"
KEYCLOAK_DIR="/opt/keycloak"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Create PostgreSQL Database and User
echo "Configuring PostgreSQL..."
sudo -i -u postgres psql << EOF
CREATE DATABASE $DB_NAME;
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOF

# Download and Install Keycloak
echo "Installing Keycloak..."
wget https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-oidc-js-adapter-$KEYCLOAK_VERSION.tar.gz -O /tmp/keycloak.tar.gz
sudo tar -xzf /tmp/keycloak.tar.gz -C /opt
sudo mv /opt/keycloak-oidc-js-adapter-$KEYCLOAK_VERSION $KEYCLOAK_DIR

# Configure Keycloak
echo "Configuring Keycloak..."
sudo mkdir -p $KEYCLOAK_DIR/conf
sudo tee $KEYCLOAK_DIR/conf/keycloak.conf > /dev/null << EOF
keycloak.database.url=jdbc:postgresql://localhost:5432/$DB_NAME
keycloak.database.user=$DB_USER
keycloak.database.password=$KEYCLOAK_PASSWORD
EOF

# Create Keycloak Service File
echo "Creating Keycloak service file..."
sudo tee /etc/systemd/system/keycloak.service > /dev/null << EOF
[Unit]
Description=Keycloak Server
After=network.target

[Service]
# User=keycloak
# Group=keycloak
Environment=JAVA_HOME=$JAVA_HOME
ExecStart=$KEYCLOAK_DIR/bin/kc.sh start-dev
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload Systemd and Start Keycloak
echo "Starting Keycloak service..."
sudo systemctl daemon-reload
sudo systemctl enable keycloak
sudo systemctl start keycloak

# Verify Keycloak Status
echo "Verifying Keycloak status..."
sudo systemctl status keycloak

echo "Keycloak setup completed successfully!"
echo "http://localhost:8080"
