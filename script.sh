#!/bin/bash

# Install prerequisites
apt update
apt install -y curl build-essential

# Install latest version of Node.js
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

# Install Haraka
npm -g config set user root
npm install -g Haraka
haraka -i /root/haraka

# Configure SMTP settings
sed -i 's/#listen=0.0.0.0:25/listen=0.0.0.0:587/' /root/haraka/config/smtp.ini

# Enable TLS and authentication
sed -i '/^#tls/,/^$/ s/^#//' /root/haraka/config/plugins
sed -i '/^#auth/,/^$/ s/^#//' /root/haraka/config/plugins

# Generate self-signed SSL certificate
haraka -h tls
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /root/haraka/config/tls_key.pem -out /root/haraka/config/tls_cert.pem

# Configure SSL settings
cat <<EOT >> /root/haraka/config/tls.ini
key=/root/haraka/config/tls_key.pem
cert=/root/haraka/config/tls_cert.pem
EOT

# Create an authentication user
echo "username1:$(openssl passwd -crypt passwordgoeshere)" >> /root/haraka/config/auth_flat_file.ini

# Update the sending hostname
read -p "Enter the sending hostname: " hostname
sed -i "s/localhost/$hostname/" /root/haraka/config/smtp.ini

# Turn off outgoing received header
echo "received=false" >> /root/haraka/config/smtp.ini

# Change permissions
chmod -R 770 /root/haraka

# Create systemd service for Haraka
cat <<EOT >> /etc/systemd/system/haraka.service
[Unit]
Description=Haraka MTA
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
PIDFile=/var/run/haraka.pid
ExecStart=/usr/bin/haraka -c /root/haraka
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOT

# Enable and start Haraka service
systemctl daemon-reload
systemctl enable haraka
systemctl start haraka

echo "Haraka installation complete!"
