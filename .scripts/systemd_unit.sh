#!/bin/bash
setup_user_systemd(){
    sudo systemctl start user@$(id -u).service
    sudo systemctl enable user@$(id -u).service
    systemctl --user status
}
install_paru(){
    tmp_dir=$(mktemp -d /tmp/paru-XXXXXXX)
sudo pacman -S --needed base-devel git && \
git clone https://aur.archlinux.org/paru.git $tmp_dir && \
cd $tmp_dir && \
makepkg -si --noconfirm && \
cd ~ && \
rm -rf $tmp_dir
}
setup_kopia(){
SCRIPT_NAME="kopia"
SCRIPT_PATH="$HOME/.scripts_encrypt/kopia_backup.sh"
WORKING_DIR="$HOME/.scripts_encrypt"
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/${SCRIPT_NAME}.service <<-'EOF'
[Unit]
Description=kopia backup hourly
After=network.target

[Service]
Type=oneshot
ExecStart=SCRIPT_PATH_PLACEHOLDER
WorkingDirectory=WORKING_DIR_PLACEHOLDER
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

sed -i "s|SCRIPT_PATH_PLACEHOLDER|$SCRIPT_PATH|g" ~/.config/systemd/user/${SCRIPT_NAME}.service
sed -i "s|WORKING_DIR_PLACEHOLDER|$WORKING_DIR|g" ~/.config/systemd/user/${SCRIPT_NAME}.service

cat > ~/.config/systemd/user/${SCRIPT_NAME}.timer <<-EOF
[Unit]
Description=hourly timer
Requires=${SCRIPT_NAME}.service

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF
systemctl --user daemon-reload
systemctl --user enable ${SCRIPT_NAME}.timer
sudo loginctl enable-linger $USER
systemctl --user start ${SCRIPT_NAME}.timer

systemctl --user status ${SCRIPT_NAME}.timer
systemctl --user status ${SCRIPT_NAME}.service
}
