mutt multiple accounts
======================

In order to use this muttrc setup you need to specify your mail account
information in certain files. For each account you can create individual files
as described below. These will override the settings in the corresponding `generic`
files.

This setup is based on my previous setup which, in turn, was based on [this setup](https://github.com/redondos/mutt/) by redondos.


file examples
-------------

- `~/.mutt/accounts/info/$id` -- the main account configuration file. The
  filename triggers the search for the other files. Example:

        set my_account = "example"
        set my_name	= "Konstantinos Koukopoulos"
        set my_uid	= "koukopoulos"
        set my_folder	= "imap.gmail.com"
        set my_from	= "$my_uid@gmail.com"
        set my_smtp	= "smtps://$my_from@smtp.gmail.com:465/"
        set my_imap	= "imaps://$my_folder"
        set my_alt	= "^koukopoulos\([+].*\)?@gmail.com|someothermail@domain.com"

- `~/.mutt/accounts/hooks/account/$id` -- commands to be hooked on account change. Example:

        set mail_check=120

- `~/.mutt/accounts/hooks/folder/$id` -- commands to be hooked on folder change. Example:

        set postponed="=[Gmail]/Drafts"
        set mbox="=[Gmail]/All Mail"
        set trash="=[Gmail]/Trash"
        set record=

- `~/.mutt/accounts/hooks/send2/$id` -- commands to be hooked on sending mail. Example:

        set signature="~/.mutt/signatures/koukopoulos"

- `~/.mutt/accounts/passwords/<id>.gpg` -- your password, encrypted with gpg
