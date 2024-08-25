#!/bin/bash
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <sec>"
    exit 1
fi
sec=$1
leftsec=$1
while true ; do
		if [[ $leftsec -eq 0 ]] ; then ring ;break; fi
		sleep 1;
		echo -en "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b$leftsec";
		leftsec=$(($leftsec-1))
done
