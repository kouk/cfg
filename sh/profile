# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi


export COLORFGBG="brightblue;white"
export CLICOLOR=true
export EDITOR=vim
export FCEDIT=vim
export BROWSER=opera
export PAGER=less
# java options
for i in java appletviewer javaws opera ; do
	eval 'export JAVAVM_OPTS_'$i'="-Djava.net.preferIPv4Stack=true -Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true"'
done
export _JAVA_AWT_WM_NONREPARENTING=1
