#!/bin/bash
FOLDER=$HOME/.config/clash
# FOLDER=$HOME/.config/clash_win
FILE=config_$(date +%y%m%d_%k:%0l:%S_%N).yaml
WIN_FILE="/mnt/d/Users/Administrator/.config/clash/profiles/1707726507266.yml"
LINK="https://mojie.app/api/v1/client/subscribe?token=0ce896d17bde60480c9e1a8bb540b29e""&flag=clash"
mkdir -p $FOLDER
wget --no-proxy "$LINK" -O "$FOLDER"/"$FILE"
# wget "$LINK" -O "$FOLDER"/"$FILE"
if [[ -f "$FOLDER"/"$FILE"  && -s "$FOLDER"/"$FILE" ]]; then 
# sed -i '/^secret.*/d' "$FOLDER"/"$FILE"
# sed -i "s/external-controller:.*/external-controller: \'127.0.0.1:9090\'/g" "$FOLDER"/"$FILE"
# sed -i "s/ipv6.*/ipv6: true/g" "$FOLDER"/"$FILE"
# sed -i "s/allow-lan.*/allow-lan: true/g" "$FOLDER"/"$FILE"

sed -i "/rules/a\    - \'DOMAIN-SUFFIX,claude.ai,ChatGPT\'" "$FOLDER"/"$FILE"
sed -i "/rules/a\    - \'DOMAIN-SUFFIX,anthropic.com,ChatGPT\'" "$FOLDER"/"$FILE"
sed -i "/rules/a\    - \'DOMAIN-KEYWORD,anthropic,ChatGPT\'" "$FOLDER"/"$FILE"

sed -i "/rules/a\    - \'DOMAIN-SUFFIX,chat.openai.com,ChatGPT\'" "$FOLDER"/"$FILE"
sed -i "/rules/a\    - \'DOMAIN-SUFFIX,ke.newschool.com,节点选择\'" "$FOLDER"/"$FILE"
rm "$FOLDER"/config.yaml
ln -s "$FOLDER"/"$FILE" "$FOLDER"/config.yaml
cat "$FOLDER"/"$FILE" > "$WIN_FILE"
echo "更新成功"
else
echo "更新失败"
rm "$FOLDER"/"$FILE" 2>/dev/null
fi
