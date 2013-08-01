case $- in *i*) ;; *) return ;; esac

for fp in "/usr/share/ksh/functions" \
          "/usr/local/share/examples/ksh93"
do
    if [ -d $fp ] ; then
        FPATH+="$fp"
    fi
done

TILDE='~'
PS1="$(hostname -s):"'${TILDE[(1-0${PWD%%@([!!/]*|$HOME*)}1)]-}${PWD#$HOME}'

case "$TERM" in
xterm*|rxvt*|screen)
    PS1="]0;$PS1$PS1"
    ;;
*)
    ;;
esac

PS1="$PS1\$ "

. ~/.shrc

precmd () (
    # Your commands
    # ...
    echo -ne '\a'
)
tmxcycle && exit

