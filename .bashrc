PS1='\h:\w'

. ~/.shrc

_nprx="[^[:print:]][[:print:]]*[^[:print:]]"

PS1=$(echo "$PS1" | 
    sed -e 's/\('$_nprx'\)/\\[\1\\]/g')

shopt -s checkwinsize

bash_completion=$(dirname $SHELL)/../etc/bash_completion
if [ -f $bash_completion ] && ! shopt -oq posix; then
    . $bash_completion
fi
unset bash_completion

#wtf?
#export PROMPT_COMMAND="echo -ne '\a'"

tmxcycle
