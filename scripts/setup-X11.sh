## This script installs X11 and sets up a xinit service
## xterm is running in foreground until the klipperscreen
## container connects to the xserver

#!/bin/bash

set -xe

## Name of the new user
USER=pi

## Install Packages
apt update
packages=(
    feh
    xterm
    xinit
    xinput
    xserver-xorg
    xserver-xorg-legacy
    x11-xserver-utils
    xserver-xorg-video-fbdev
)

## Install only missing packages
for pkg in "${packages[@]}"; do
    if dpkg -s "$pkg" &> /dev/null; then
        echo "Package $pkg is already installed, skipping..."
    else
        echo "Installing $pkg..."
        apt install -y "$pkg"
    fi
done

## Allow any User to start X
if [ -f /etc/X11/Xwrapper.config ]; then
  sed -i 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config
else
  cat <<EOF > /etc/X11/Xwrapper.config
needs_root_rights=yes
allowed_users=anybody
EOF
fi

## Create the xinit systemd service
cat <<EOF > /etc/systemd/system/xinit.service
[Unit]
Description=Autologin to X
After=systemd-user-sessions.service

[Service]
User=${USER}
ExecStart=/usr/bin/xinit /usr/bin/feh -FY /home/pi/prind/img/splashscreen-1080p-dark.png

[Install]
WantedBy=multi-user.target
EOF

## Reload, enable and start the xinit service
systemctl daemon-reload
systemctl enable xinit.service
systemctl start xinit
