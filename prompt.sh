if [ `uname -s` == "Darwin" ]
then
  # Awesome Mac OS Terminal prompt that uses xterm-256 color and Unicode color emoji
  PS1='\[\033[38;5;27m\]\w$(__git_ps1 " (%s)")\[\033[00m\] 👌  ' 
else
  #Purdy git-aware prompt that works on any *nix system
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[00;34m\]\w$(__git_ps1 " (%s)")\[\033[00m\]\$ '
fi

