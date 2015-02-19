# I like to keep my GOPATH in a specific, consistent place
if [ -d $HOME/Code/go ]
then
  export GOPATH=$HOME/Code/go
  export PATH=$PATH:$HOME/Code/go/bin
fi
