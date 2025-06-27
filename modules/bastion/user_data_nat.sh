#!/bin/bash
# filepath: d:\projects\rs\rsschool-devops-course-tasks\modules\bastion\user_data_nat.sh
# Update package list
apt update -y

# Pre-configure iptables-persistent to avoid interactive prompts
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

# Install iptables-persistent to save rules across reboots
DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent

# Enable IP forwarding for NAT functionality
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Get the primary network interface name (usually eth0 or ens5)
PRIMARY_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

# Clear existing iptables rules
iptables -F
iptables -t nat -F
iptables -X

# Configure iptables for NAT - MASQUERADE traffic going out through primary interface
iptables -t nat -A POSTROUTING -o $PRIMARY_INTERFACE -j MASQUERADE

# Allow forwarding for established and related connections
iptables -A FORWARD -i $PRIMARY_INTERFACE -o $PRIMARY_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow forwarding from private subnets to public interface
iptables -A FORWARD -i $PRIMARY_INTERFACE -o $PRIMARY_INTERFACE -j ACCEPT

# More specific rules for better security
# Allow forwarding from VPC CIDR to internet
iptables -A FORWARD -s 10.0.0.0/16 -o $PRIMARY_INTERFACE -j ACCEPT
iptables -A FORWARD -i $PRIMARY_INTERFACE -d 10.0.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Save iptables rules
iptables-save > /etc/iptables/rules.v4

# Ensure rules persist on reboot
systemctl enable netfilter-persistent

# Install and start apache2 for testing connectivity
DEBIAN_FRONTEND=noninteractive apt install -y apache2
systemctl start apache2
systemctl enable apache2

# Create a simple index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>NAT Instance (Ubuntu)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f8ff; }
        .container { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #ff6600; }
        .info { background-color: #ffe6cc; padding: 15px; border-radius: 4px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>NAT Instance (Ubuntu)</h1>
        <div class="info">
            <h3>Instance Information:</h3>
            <p><strong>Private IP:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)</p>
            <p><strong>Public IP:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</p>
            <p><strong>Availability Zone:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
            <p><strong>Instance ID:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
            <p><strong>IP Forwarding:</strong> \$(cat /proc/sys/net/ipv4/ip_forward)</p>
            <p><strong>Primary Interface:</strong> $PRIMARY_INTERFACE</p>
        </div>
        <p>This Ubuntu instance is configured as a NAT server for private subnet instances.</p>
        <div class="info">
            <h3>NAT Configuration:</h3>
            <p>- IP forwarding enabled</p>
            <p>- MASQUERADE configured for outbound traffic</p>
            <p>- Forward rules configured for VPC CIDR (10.0.0.0/16)</p>
        </div>
    </div>
</body>
</html>
EOF

# Set proper permissions
chown www-data:www-data /var/www/html/index.html
chmod 644 /var/www/html/index.html

# Log the configuration for debugging
echo "NAT instance setup completed at $(date)" >> /var/log/nat-setup.log
echo "Primary interface: $PRIMARY_INTERFACE" >> /var/log/nat-setup.log
echo "IP forwarding status: $(cat /proc/sys/net/ipv4/ip_forward)" >> /var/log/nat-setup.log
iptables -L -n >> /var/log/nat-setup.log
iptables -t nat -L -n >> /var/log/nat-setup.log