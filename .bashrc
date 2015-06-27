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

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

for bash_completion in $(dirname $SHELL)/../etc/bash_completion \
    /etc/profile.d/bash_completion ; do
    if [ -f $bash_completion ] && ! shopt -oq posix; then
        . $bash_completion
    fi
done

#wtf?
#export PROMPT_COMMAND="echo -ne '\a'"

tmxcycle
