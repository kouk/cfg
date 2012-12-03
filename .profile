if [ -n "$BASH_VERSION" ] ; then
    ENV="$HOME/.bashrc"
    case $- in *i*) [ -f "$ENV" ] && . "$ENV" ; esac
elif [ -n "$KSH_VERSION" ] ; then
    ENV="$HOME/.kshrc"
else
    ENV="$HOME/.shrc"
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

if [ -d ~/.profile.d ]; then
   for f in ~/.profile.d/* ; do 
      . $f
   done
fi

add_path ~/.local/bin
for d in ~/.local/bin/* ; do
   [ -d $d ] && add_path $d
done
