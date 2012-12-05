#!/bin/sh

for a in ~/.mutt/accounts/* ; do
    cat $a
    printf '\nunset folder\n'
done

grep "^set folder" ~/.mutt/accounts/00.default 
