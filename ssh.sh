# Automatically add all private keys to agent
if [ -n "$SSH_AUTH_SOCK" ]
then
  private_keys=`grep -El 'BEGIN [A-Z]+ PRIVATE KEY' ~/.ssh/*`
  if [[ $? == 0 && -n $private_keys ]]; then
    ssh-add $private_keys 2> /dev/null

    if [[ $? != 0 ]]; then
      echo "Could not auto-add private SSH keys"
      echo "Please run this command by hand:"
      echo "ssh-add $private_keys"
    fi
  fi
fi

# Handy function to open an SSH connection with port forwarding
tunnel() {
  local host="$1"
  local port="$2"
  local lport="1${port}"
  echo "Tunneling ${host}:${port} to localhost:${lport}"
  ssh -L ${lport}:localhost:${port} $host
}

