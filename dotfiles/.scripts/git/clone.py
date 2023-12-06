#!/usr/bin/env python
import subprocess
import sys
urllist=[
        'https://gitee.com/moieo/tneovim',
        'https://github.com/nicknisi/dotfiles',
        'https://github.com/kristijanhusak/neovim-config',
        'https://github.com/xero/dotfiles',
        'https://github.com/Olical/dotfiles',
        'https://github.com/awesome-streamers/awesome-streamerrc',
        'https://github.com/wsdjeg/.SpaceVim.d',
        'https://github.com/semanser/dotfiles',
        'https://github.com/Netherdrake/Dotfiles',
        'https://github.com/antoniosarosi/dotfiles',
        'https://github.com/davidosomething/dotfiles',
        'https://github.com/ctaylo21/jarvis',
        'https://github.com/onlurking/termux',
        'https://github.com/joshukraine/dotfiles',
        'https://github.com/wookayin/dotfiles',
        'https://github.com/AGou-ops/dotfiles',
        'https://github.com/dikiaap/dotfiles',
        'https://github.com/FelixKratz/dotfiles'
        'https://github.com/siduck/dotfiles',
        'https://github.com/numToStr/dotfiles',
        'https://github.com/blueyed/dotfiles',
        'https://github.com/geodimm/dotfiles',
        'https://github.com/linuxmobile/hyprland-dots',
        'https://github.com/caarlos0/dotfiles.fish',
        'https://github.com/lokesh-krishna/dotfiles',
        'https://github.com/wbthomason/dotfiles',
        'https://github.com/yutkat/dotfiles',
        'https://github.com/akinsho/dotfiles',
        'https://github.com/zchee/.nvim',
        'https://github.com/m4xshen/dotfiles',
        'https://github.com/joshmedeski/dotfiles',
        ]

if __name__ == "__main__":
    for url in urllist:
        path=url.split('/')[-1]+'_from_'+url.split('/')[-2]
        print(path)
        try:
            subprocess.run(['git','clone',url,path],check=True)
        except KeyboardInterrupt:
            print("Ctrl+C pressed, exiting...")
            sys.exit(1)
        except:
            print(f'\033[31merror whlie clone {url}\033[0m')
            continue
