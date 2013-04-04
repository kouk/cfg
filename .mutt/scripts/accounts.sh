#!/bin/sh

i=0

for a in ~/.mutt/accounts/info/* ; do
    name=$(basename $a)
    printf 'set my_index=%s\n' $i
    cat $a
    grep -q my_alt $a  && printf 'alternates "$my_alt"\n'
    grep -q my_imap $a && printf 'mailboxes "$my_imap/INBOX"\n'
    account_tmpl='account-hook $my_folder "source %s"\n'
    send2_tmpl='send2-hook "~f $my_from" "source %s"\n'
    folder_tmpl='folder-hook $my_folder "source %s"\n'
    for h in account send2 folder ; do
        eval tmpl=\$${h}_tmpl
        d=~/.mutt/accounts/hooks/$h
        printf "$tmpl" $a
        [ -f $d/generic ] && printf "$tmpl" $d/generic
        [ -f $d/$name ]   && printf "$tmpl" $d/$name
    done
    pw=~/.mutt/accounts/passwords/$name.gpg
    if [ -f $pw ] ; then
        printf 'account-hook $my_folder "set imap_pass=`gpg --batch -q --decrypt %s`"\n' $pw
        printf 'send2-hook "~f ^$my_from" "set smtp_pass=`gpg --batch -q --decrypt %s`"\n' $pw
    fi
    i=$(expr $i + 1)
done

