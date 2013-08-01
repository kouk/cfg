case "$TERM" in
xterm*|rxvt*|screen)
    PS1='\[]0;\h:\w\]\h:\w'
    ;;
*)
    PS1='\h:\w'
    ;;
esac

if type __git_ps1 >/dev/null 2>&1 ; then
    PS1=${PS1}'[0;32m$(__git_ps1)[m\]'
fi

. ~/.shrc

PS1="$PS1\$ "


shopt -s checkwinsize

for bash_completion in $(dirname $SHELL)/../etc/bash_completion \
    /etc/profile.d/bash_completion ; do
    if [ -f $bash_completion ] && ! shopt -oq posix; then
        . $bash_completion
    fi
done

#wtf?
#export PROMPT_COMMAND="echo -ne '\a'"

tmxcycle
