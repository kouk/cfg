#!/bin/sh
if [ -r $HOME/.wpa_action ] ; then
    wpa_cli -a $HOME/.wpa_action
fi
