#!/bin/bash 
FAILED=;
select pkgmanager in "apt-get" "pkg" "pacman" "paru" "scoop";do
    case $pkgmanager in
        apt-get ) 
            sudo apt-get update
            for i in "clangd" "clang" "gcc" "gdb" "g++" "git" "python" "python-pip" "nodejs" "pnpm" "fnm" "tree-sitter" "fd" "ripgrep" ; do 
                echo "sudo apt-get install -y $i"
                sudo apt-get install -y $i || FAILED=$i,$FAILED
            done
            pip install pynvim || FAILED=pynvim,$FAILED
            break
            ;;
        pkg ) 
            for i in "clangd" "clang" "gcc" "gdb" "g++" "git" "python" "python-pip" "nodejs" "pnpm" "fnm" "tree-sitter" "fd" "ripgrep" ; do 
                echo "pkg install -y $i"
                pkg install -y $i|| FAILED=$i,$FAILED
            done
            pip install pynvim|| FAILED=pynvim,$FAILED
            break
            ;;
        pacman |paru)
            if !command -v paru &>/dev/null; then
                echo "install paru"
                tmp=$(mktemp -d)
                sudo pacman -S --needed base-devel git || exit 1
                while ! git clone https://aur.archlinux.org/paru.git $tmp ; do echo reclone; done
                cd $tmp || exit 1
                yes|makepkg -si || exit 1
                cd -
                rm -rf $tmp
            fi
            if !command -v paru &>/dev/null; then
                echo "paru not found"
                exit 1
            fi
            for i in "clangd" "clang" "gcc" "gdb" "g++" "git" "python" "python-pip" "python-pynvim" "nodejs" "pnpm" "fnm" "tree-sitter" "fd" "ripgrep" ; do 
                echo "paru -S --noconfirm $i"
                paru -S --noconfirm $i || FAILED=$i,$FAILED
            done
            break
            ;;
        scoop ) 
            for i in "clangd" "clang" "gcc" "gdb" "g++" "git" "python" "python-pip" "nodejs" "pnpm" "fnm" "tree-sitter" "fd" "ripgrep" ; do 
                echo "scoop install $i"
                scoop install $i || FAILED=$i,$FAILED
            done
            pip install pynvim || FAILED=pynvim,$FAILED
            break
            ;;
    esac
done
echo -e "以下失败\n$FAILED"
