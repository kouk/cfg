#!/bin/sh

i=0

set - ~/.mutt/accounts/info/* 

echo "set my_account_$#=\$my_account_$i"
while [ $# -gt 0 ] ; do
    echo -n "set my_account_$i="
    shift
    i=$(expr $i + 1)
    echo "\$my_account_$i"
done
echo "source ~/.mutt/accounts/info/\$my_account_0"
echo "source ~/.mutt/accounts/macros/\$my_account_1"
