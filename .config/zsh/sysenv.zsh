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

SYSNAMEALL=$(uname -a)
SYSARCH=$(uname -m)
#PLEASE ENSURE ZSH VERSION>=5.0.8
SYSNAMEALL="${SYSNAMEALL:l}" 
SYSARCH="${SYSARCH:l}"

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
        ISNIX=1;ISMAC=1;
        ;;
    *msys*)
        ISNIX=1;ISMSYS=1;
        ;;
    *cygwin*)
        ISNIX=1;ISCYGWIN=1;
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
