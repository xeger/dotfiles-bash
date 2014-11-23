alias dr="docker run -d"
alias drm="docker rm -f"
alias dps="docker ps"
alias dgc="docker gc ; docker gci"
alias dsh="docker shell"

# Boot2docker integration for Mac/Windows systems
if [ -f /usr/local/bin/boot2docker ]
then
  function docker() {
    exe=/usr/local/bin/boot2docker

    ( $exe status | grep -q running ) || {
      $exe init
      $exe start
    }
  
    if [ -z "$DOCKER_HOST" ]
    then
      $($exe shellinit)
    fi

    if [ "$1" == "gc" ]
    then
      for cont in `docker ps -q -a --filter=[status=exited]`
      do
        docker rm -f $cont
      done
    elif [ "$1" == "gci" ]
    then
       for img in `docker images | grep '<none>' | cut -b 41-52` 
       do
         docker rmi -f $img
       done 
    elif [ "$1" == "shell" ]
    then
      docker exec -t -i $2 /bin/bash
    else
      /usr/local/bin/docker $@
    fi
  }
fi

