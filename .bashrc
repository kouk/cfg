PS1='\h:\w'

. ~/.shrc

shopt -s checkwinsize

bash_completion=$(dirname $SHELL)/../etc/bash_completion
if [ -f $bash_completion ] && ! shopt -oq posix; then
    . $bash_completion
fi
unset bash_completion
