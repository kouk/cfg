#!/bin/sh

if [ -f $HOME/.config/local.xrdb ] ; then
    xrdb -merge $HOME/.config/local.xrdb
fi
