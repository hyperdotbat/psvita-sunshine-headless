#!/bin/bash
cd "$(dirname "$0")" || exit 1
set -euo pipefail

KERNEL_PARAM="video=HDMI-A-1:e drm_kms_helper.edid_firmware=HDMI-A-1:edid/720p.bin"

echo
echo "Note down your current display manager if needed:"
systemctl status display-manager || true

read -p "Do you want to disable your current display-manager (Y/n): " answer
answer="${answer,,}"
if [[ "$answer" == "" || "$answer" == "y" || "$answer" == "yes" ]]; then
    sudo systemctl disable display-manager
elif [[ "$answer" == "n" || "$answer" == "no" ]]; then
    echo
fi

echo
echo "Enabling linger for $USER"
loginctl enable-linger "$USER"

echo
echo "Copying xorg-headless.service to /etc/systemd/system/xorg-headless.service and enabling:"
sudo cp -i ./etc/systemd/system/xorg-headless.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/xorg-headless.service
sudo systemctl enable xorg-headless

echo
echo "Copying the EDID file to /usr/lib/firmware/edid/720p.bin:"
sudo mkdir -p /usr/lib/firmware/edid
sudo cp -i ./usr/lib/firmware/edid/720p.bin /usr/lib/firmware/edid/
sudo chown root:root /usr/lib/firmware/edid/720p.bin

echo
read -p "Do you want to modify /etc/default/grub to set kernel parameter for EDID [will only replace if no other parameters are set] (Y/n): " answer
answer="${answer,,}"
if [[ "$answer" == "" || "$answer" == "y" || "$answer" == "yes" ]]; then
    if grep -q '^GRUB_CMDLINE_LINUX=""' /etc/default/grub; then
        echo "GRUB_CMDLINE_LINUX is empty - setting kernel parameters"
        echo "GRUB_CMDLINE_LINUX=\"$KERNEL_PARAM\""
        sudo sed -i \
            "s|^GRUB_CMDLINE_LINUX=\"\"|GRUB_CMDLINE_LINUX=\"${KERNEL_PARAM}\"|" \
            /etc/default/grub
    else
        echo "GRUB_CMDLINE_LINUX is not empty - skipping automatic modification"
        echo "Please add the following parameters manually if needed:"
        echo "$KERNEL_PARAM"
    fi
elif [[ "$answer" == "n" || "$answer" == "no" ]]; then
    echo
fi
echo "its recommended you check /etc/default/grub yourself now to see if that parameter is there"
echo "if needed go there and replace HDMI-A-1 with whichever is free:"
chmod +x check-displays.sh
./check-displays.sh

echo
echo "Updating grub:"
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo
echo "Copying all necessary scripts to $HOME/.local/bin/"
chmod +x scripts/*
cp -i ./scripts/* "$HOME/.local/bin/"

echo
echo "Enabling Sunshine"
systemctl --user enable sunshine || {
    echo "Warning: could not enable sunshine user service"
}

echo
read -p "Do you want to copy the apps.json file to $HOME/.config/sunshine/? (Y/n): " answer
answer="${answer,,}"
if [[ "$answer" == "" || "$answer" == "y" || "$answer" == "yes" ]]; then
    echo "Copying apps.json to $HOME/.config/sunshine/apps.json"
    cp -i ./.config/sunshine/apps.json "$HOME/.config/sunshine/"
elif [[ "$answer" == "n" || "$answer" == "no" ]]; then
    echo
fi

echo
echo "If you did the kernel parameter thing and all is good, youre free to reboot now"