WSPATH="$(lsblk -o UUID,MOUNTPOINT | grep 9438C15E38C1404A | awk '{print$2}')"
[[ -n $WSPATH ]] && rsync --delete -avz "$HOME"/workspace/ "$WSPATH"/workspace/linux
