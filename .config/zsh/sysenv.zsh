## THIS SCRIPT SHOULE BE LOAD AT FIRST
########################################## OS ARCH VARABLE ##########################################
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
IS_NIX=false
    ISLINUX=false
        ISANDROID=false
        ISWSL=false
    ISMAC=false
    ISMSYS=false
    ISCYGWIN=false
IS_WIN=false

IS_ARM64=false
IS_AMD64=false

SYSNAMEALL=$(uname -a)
SYSARCH=$(uname -m)
#PLEASE ENSURE ZSH VERSION>=5.0.8
SYSNAMEALL="${SYSNAMEALL:l}" 
SYSARCH="${SYSARCH:l}"

case $SYSNAMEALL in
    *linux*)
        IS_NIX=true;ISLINUX=true;
        case $(uname -a) in
            *microsoft*)
                ISWSL=true;
                ;;
            *android*)
                ISANDROID=true;
                ;;
            *)# Common Linux
                ;;
        esac
        ;;
    *darwin*)
        ISNIX=true;ISMAC=true;
        ;;
    *msys*)
        ISNIX=true;ISMSYS=true;
        ;;
    *cygwin*)
        ISNIX=true;ISCYGWIN=true;
        ;;
    *windows_nt*)
        IS_WIN=true;
        ;;
    *)
        ;;
esac
case $SYSARCH in
    *arm64*|*aarch64*)
        IS_ARM64=true;
        ;;
    *x86_64*)
        IS_AMD64=true;
        ;;
    *)
        ;;
esac
unset SYSNAMEALL
unset SYSARCH
