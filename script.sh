#!/bin/bash

# Update the package list
sudo apt-get update

# Install Postfix and OpenSSL
sudo apt-get install postfix openssl

# Prompt the user for the email address, password, and hostname
read -p "Enter your email address: " email
read -sp "Enter your email password: " password
echo
read -p "Enter the hostname for your server: " hostname

# Generate a self-signed SSL certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/postfix.key -out /etc/ssl/certs/postfix.crt -subj "/CN=$hostname"

# Configure Postfix to use the SSL certificate
sudo postconf -e "smtpd_tls_cert_file = /etc/ssl/certs/postfix.crt"
sudo postconf -e "smtpd_tls_key_file = /etc/ssl/private/postfix.key"
sudo postconf -e "smtp_tls_cert_file = /etc/ssl/certs/postfix.crt"
sudo postconf -e "smtp_tls_key_file = /etc/ssl/private/postfix.key"
sudo postconf -e "smtpd_use_tls = yes"
sudo postconf -e "smtp_use_tls = yes"

# Configure Postfix to use the provided email address and password
sudo postconf -e "relayhost = [$email]:587"
sudo postconf -e "smtp_sasl_auth_enable = yes"
sudo postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
sudo postconf -e "smtp_sasl_security_options = noanonymous"
echo "[$email]:587 $email:$password" | sudo tee -a /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd

# Turn off the outgoing Received header
sudo postconf -e "disable_vrfy_command = yes"
sudo postconf -e "smtpd_discard_ehlo_keyword_address_maps = hash:/etc/postfix/discard"
echo "received discard_it" | sudo tee -a /etc/postfix/discard
sudo postmap /etc/postfix/discard

# Restart Postfix to apply the changes
sudo service postfix restart
