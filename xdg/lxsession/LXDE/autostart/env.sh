#!/bin/sh

export _LXSESSION_PID=$(pgrep -u $USER -f -x x-session-manager)
