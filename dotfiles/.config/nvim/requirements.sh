#!/bin/bash 
select pkgmanager in "apt-get" "pkg" "pacman" "paru" "scoop";do
    case $pkgmanager in
        apt-get ) 
            for i in "python3 python3-pip nodejs" ; do 
                sudo apt-get install -y $i
            done
            pip install pynvim
            break
            ;;
        pkg ) 
            for i in "python3 python3-pip nodejs" ; do 
                pkg install -y $i
            done
            pip install pynvim
            break
            ;;
        pacman ) 
            for i in "" ; do 
                sudo pacman -S --noconfirm $i
            done
             break
            ;;
        paru ) 
            for i in "python python-pip python-pynvim nodejs" ; do 
                sudo paru -S --noconfirm $i
            done
            break
            ;;
        scoop ) 
            for i in "python python-pip nodejs" ; do 
                scoop install $i
            done
            pip install pynvim
            break
            ;;
    esac
done
