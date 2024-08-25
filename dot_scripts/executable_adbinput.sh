#!/usr/bin/env bash
# $0 key [dev]
if [ $# -lt 1 ]; then
    echo "Usage: $0 key [dev]"
    exit 1
fi
Key="$1"
if [[ -n "$2" ]]; then
    Dev="$2"
else
    Dev=;
fi
source keycode.conf
if [[ -n "$Dev" ]]; then
    adb -s $Dev shell input keyevent $(eval 'echo $'"KEYCODE_$Key")
else
    adb shell input keyevent $(eval 'echo $'"KEYCODE_$Key")
fi
