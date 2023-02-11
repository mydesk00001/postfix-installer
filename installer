#!/bin/bash

# Install postfix
sudo apt-get update
sudo apt-get install postfix -y

# Install OpenSSL
sudo apt-get install openssl -y

# Prompt for hostname, mail user, and password
read -p "Enter hostname: " hostname
read -p "Enter mail user: " mailuser
read -p "Enter password: " -s password

# Generate SSL certificate using OpenSSL
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$hostname.key -out /etc/ssl/certs/$hostname.crt \
-subj "/C=US/ST=CA/L=San Francisco/O=Company Name/OU=Org/CN=$hostname"

# Set permissions on SSL files
sudo chmod 600 /etc/ssl/private/$hostname.key
sudo chmod 644 /etc/ssl/certs/$hostname.crt

# Set postfix configurations
sudo postconf -e "myhostname = $hostname"
sudo postconf -e "smtpd_banner = "
sudo postconf -e "smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination"
sudo postconf -e "smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination"
sudo postconf -e "smtpd_sasl_auth_enable = yes"
sudo postconf -e "smtpd_sasl_authenticated_header = yes"
sudo postconf -e "smtpd_sasl_local_domain ="
sudo postconf -e "smtpd_sasl_security_options = noanonymous"
sudo postconf -e "smtpd_tls_auth_only = yes"
sudo postconf -e "smtpd_tls_cert_file = /etc/ssl/certs/$hostname.crt"
sudo postconf -e "smtpd_tls_key_file = /etc/ssl/private/$hostname.key"
sudo postconf -e "smtpd_tls_loglevel = 1"
sudo postconf -e "smtpd_tls_security_level = may"
sudo postconf -e "smtpd_use_tls = yes"
sudo postconf -e "virtual_alias_maps = hash:/etc/postfix/virtual"
sudo postconf -e "header_checks = regexp:/etc/postfix/header_checks"

# Create virtual alias map
sudo touch /etc/postfix/virtual
sudo echo "$mailuser@$hostname $mailuser" >> /etc/postfix/virtual
sudo postmap /etc/postfix/virtual

# Create header_checks file
sudo touch /etc/postfix/header_checks
sudo echo "/^Received:/ IGNORE" >> /etc/postfix/header_checks

# Restart postfix
sudo service postfix restart
