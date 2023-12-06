#!/bin/bash
function find_cargo_dir {
    if [ -f "Cargo.toml" ]; then
        return 0
    elif [ "$(pwd)" == "/" ]; then
        return 1
    else
        cd ..
        find_cargo_dir
        return $?
    fi
}

if find_cargo_dir ; then 
    pwd
else
   echo "No Cargo.toml found"
fi
