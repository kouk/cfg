TILDE='~'
PS1="$(hostname -s):"'${TILDE[(1-0${PWD%%@([!!/]*|$HOME*)}1)]-}${PWD#$HOME}'

. ~/.shrc

precmd () (
    # Your commands
    # ...
    echo -ne '\a'
)
tmxcycle
