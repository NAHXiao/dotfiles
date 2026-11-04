cat &>/dev/null <<-EOF
.
├── nix(root)
│   ├── linux
│   │   ├── Android
│   │   ├── WSL
│   │   └── ...
│   ├── macos
│   └── msys
└── windows
EOF
IS_NIX=;
    ISLINUX=;
        ISANDROID=;
        ISWSL=;
    ISMAC=;
    ISMSYS=;
    ISCYGWIN=;
IS_WIN=;

IS_ARM64=;
IS_AMD64=;

SYSNAMEALL=$(uname -a | tr '[:upper:]' '[:lower:]')
SYSARCH=$(uname -m | tr '[:upper:]' '[:lower:]')

case $SYSNAMEALL in
    *linux*)
        IS_NIX=1;ISLINUX=1;
        case $(uname -a) in
            *microsoft*)
                ISWSL=1;
                ;;
            *android*|*Android*)
                ISANDROID=1;
                ;;
            *)# Common Linux
                ;;
        esac
        ;;
    *darwin*)
        IS_NIX=1;ISMAC=1;
        ;;
    *msys*)
        IS_NIX=1;ISMSYS=1;
        ;;
    *cygwin*)
        IS_NIX=1;ISCYGWIN=1;
        ;;
    *windows_nt*)
        IS_WIN=1;
        ;;
    *)
        ;;
esac
case $SYSARCH in
    *arm64*|*aarch64*)
        IS_ARM64=1;
        ;;
    *x86_64*)
        IS_AMD64=1;
        ;;
    *)
        ;;
esac
unset SYSNAMEALL
unset SYSARCH

################WSL适配#################
if (( ISWSL )) ;then
    function wsl_split_winpath(){
        export WINPATH=$(command printenv PATH | command perl -ne 'print join(":", grep { /\/mnt\/[a-z]/ } split(/:/));')
        export PATH=$(command printenv PATH | command perl -ne 'print join(":", grep { !/\/mnt\/[a-z]/ } split(/:/));')
    }
    [[ -z $WINPATH ]] && wsl_split_winpath

    # fix MESA:ZINK(VK_ERROR_INCOMPATIBLE_DRIVER) error
    export GALLIUM_DRIVER=llvmpipe
fi
################WSL适配#################
umask 022
