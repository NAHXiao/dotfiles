#!/bin/sh
[ -d "$HOME/.config/chezmoi.tmp" ] && rm -rf "$HOME/.config/chezmoi.tmp"
[ -d "$HOME/.config/chezmoi" ] && mv "$HOME/.config/chezmoi" "$HOME/.config/chezmoi.old"
trapfunc(){
    echo "Restoring chezmoi config"
    [ -d "$HOME/.config/chezmoi" ] && rm -rf "$HOME/.config/chezmoi"
    [ -d "$HOME/.config/chezmoi.old" ] && mv "$HOME/.config/chezmoi.old" "$HOME/.config/chezmoi"
}
trap trapfunc EXIT

test_envchg(){
    #chezmoi使用XDG_CONFIG_HOME
    rm -rf "$HOME/.config/chezmoi"
    echo $1
    (
        CHEZMOI_TEST_TMPDIR=$(mktemp -d)
        trapfunc(){
            rm -rf "$CHEZMOI_TEST_TMPDIR"
        }
        trap trapfunc EXIT
    
        cmd=$1
    
        export HOME=$CHEZMOI_TEST_TMPDIR && echo "setting HOME to $HOME"
        export XDG_CONFIG_HOME="$HOME/.config" && echo "setting XDG_CONFIG_HOME to $XDG_CONFIG_HOME"
        eval "$cmd" && echo -n "[OK]: " || echo -n "[ERROR]: "
        echo "$cmd"
        echo "Press Anything To Continue , You can check the result in $HOME"
        read
    )
}
test_arg(){
echo $1
(
    rm -rf "$HOME/.config/chezmoi"
    CHEZMOI_TEST_TMPDIR=$(mktemp -d) && echo "setting DEST to $CHEZMOI_TEST_TMPDIR"
    trapfunc(){
        rm -rf "$CHEZMOI_TEST_TMPDIR"
    }
    trap trapfunc EXIT

    cmd=$1

    eval $cmd && echo -n "[OK]: " || echo -n "[ERROR]: "
    echo "$cmd"
    echo 
    echo "Press Anything To Continue , You can check the result in $CHEZMOI_TEST_TMPDIR"
    read
)
}
echo "-----EXCLUDE ENCRYPTED-----"
test_envchg 'chezmoi init --apply --exclude encrypted'
test_arg 'chezmoi init --apply --exclude encrypted'
echo "-----INCLUDE ENCRYPTED-----"
test_arg 'chezmoi init --apply --destination $CHEZMOI_TEST_TMPDIR'
