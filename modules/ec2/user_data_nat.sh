#!/bin/bash
yum update -y
yum install -y httpd

# Enable IP forwarding for NAT functionality
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Install iptables service for Amazon Linux 2
yum install -y iptables-services

# Configure iptables for NAT
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
/sbin/iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT

# Save iptables rules
/sbin/service iptables save

# Enable iptables service
systemctl enable iptables
systemctl start iptables

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple index page with NAT server information
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>NAT Server - ${instance_name}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f8ff; }
        .container { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #ff6600; }
        .info { background-color: #ffe6cc; padding: 15px; border-radius: 4px; margin: 10px 0; }
        .nat-info { background-color: #e6f3ff; padding: 15px; border-radius: 4px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌐 NAT Server - ${instance_name}</h1>
        <div class="info">
            <h3>Instance Information:</h3>
            <p><strong>Instance Name:</strong> ${instance_name}</p>
            <p><strong>Role:</strong> NAT Server</p>
            <p><strong>Private IP:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)</p>
            <p><strong>Public IP:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "Not available")</p>
            <p><strong>Availability Zone:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
            <p><strong>Instance ID:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
        </div>
        <div class="nat-info">
            <h3>NAT Server Status:</h3>
            <p><strong>IP Forwarding:</strong> \$(cat /proc/sys/net/ipv4/ip_forward)</p>
            <p><strong>NAT Rules:</strong> Active</p>
            <p>This instance provides internet access for private subnet instances.</p>
        </div>
        <p>This EC2 instance is running in a ${instance_type} subnet and configured as a NAT server for private instances.</p>
    </div>
</body>
</html>
EOF

# Set proper permissions
chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html
