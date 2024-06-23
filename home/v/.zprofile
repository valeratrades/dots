#
# ~/.zprofile
#

export ZDOTDIR=$HOME

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  sudo ln -sfT /usr/bin/dash /bin/sh
  exec /usr/bin/start_sway.sh
fi
