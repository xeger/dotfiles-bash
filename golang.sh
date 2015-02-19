if [ -d /usr/local/go ]
then
  export PATH=$PATH:/usr/local/go/bin
fi

if [ -d $HOME/Code/go/bin ]
then
  export PATH=$PATH:$HOME/Code/go/bin
fi
