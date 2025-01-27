#!/bin/bash

# Script to automatically set up auto-reboot and enable mysterium-node service

echo "Updating system and installing required packages..."
sudo apt update -y && sudo apt upgrade -y

# Install cron if not already installed
if ! command -v cron &> /dev/null; then
    echo "Installing cron..."
    sudo apt install -y cron
fi

# Enable and start cron service
echo "Enabling and starting cron service..."
sudo systemctl enable cron
sudo systemctl start cron

# Create the reboot script
REBOOT_SCRIPT="/root/auto-reboot.sh"
echo "Creating auto-reboot script..."
cat <<EOL > $REBOOT_SCRIPT
#!/bin/bash

# Check if reboot is required
if [ -f /var/run/reboot-required ]; then
    echo "System restart required. Rebooting now..."
    reboot
fi
EOL

# Make the script executable
echo "Making auto-reboot script executable..."
chmod +x $REBOOT_SCRIPT

# Add the script to cron for periodic execution
echo "Adding auto-reboot script to crontab..."
(crontab -l 2>/dev/null; echo "*/15 * * * * /bin/bash $REBOOT_SCRIPT") | crontab -

# Enable mysterium-node service on reboot
echo "Setting up mysterium-node service to enable and start on reboot..."
MYST_SERVICE_SCRIPT="/etc/systemd/system/enable-mysterium-node.service"
cat <<EOL > $MYST_SERVICE_SCRIPT
[Unit]
Description=Enable and Start Mysterium Node Service on Boot
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'systemctl enable mysterium-node.service && systemctl start mysterium-node.service'

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and enable the service
echo "Enabling the enable-mysterium-node service..."
sudo systemctl daemon-reload
sudo systemctl enable enable-mysterium-node.service

echo "Setup completed successfully. Your server will reboot automatically if required, and mysterium-node.service will be enabled on boot."
