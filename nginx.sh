function nginx() {
  if [ "$1" == "start" ]; then
    sudo launchctl start homebrew.mxcl.nginx
  elif [ "$1" == "stop" ]; then
    sudo launchctl stop homebrew.mxcl.nginx
  elif [i "$1" == "restart" ]; then
    sudo launchctl stop homebrew.mxcl.nginx
    sudo launchctl start homebrew.mxcl.nginx
  else
    echo "Unknown command $1"
  fi
}

