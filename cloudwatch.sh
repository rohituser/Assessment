#!/bin/bash
yum update -y
yum install -y awslogs

# Configure CloudWatch Agent
cat <<EOF > /etc/awslogs/awslogs.conf
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/messages]
file = /var/log/messages
log_group_name = /ec2/system/messages
log_stream_name = {instance_id}

[/var/log/nginx/access.log]
file = /var/log/nginx/access.log
log_group_name = /ec2/nginx/access
log_stream_name = {instance_id}

[/var/log/nginx/error.log]
file = /var/log/nginx/error.log
log_group_name = /ec2/nginx/error
log_stream_name = {instance_id}
EOF

# Set region in awscli
echo "region = us-east-1" >> /etc/awslogs/awscli.conf

# Enable and start the log agent
systemctl enable awslogsd
systemctl start awslogsd
