
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
