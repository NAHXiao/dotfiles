#!/bin/bash

while IFS=: read dev desc ;do
    case $desc in 
        *[Mm]ouse* ) mousedev=$dev;;
    esac 
done < <(evemu-describe <<<'' 2>&1)
echo "mousedev: $mousedev"
[ -c "$mousedev" ] && 
    evemu-event $mousedev --type EV_REL --code REL_X --value $1 &&
    evemu-event $mousedev --type EV_REL --code REL_Y --value $2 --sync


# evemu-event $mousedev --type EV_KEY --code BTN_LEFT --value 1
# evemu-event $mousedev --type EV_SYN --code SYN_REPORT --value 0

