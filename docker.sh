alias dit="docker it"
alias dk="docker rm -f \`docker it\`"
alias drm="docker rm -f"
alias drmi="docker rmi"
alias dps="docker ps"
alias di="docker images"
alias dgc="docker gc ; docker gci"
alias dsh="docker shell"

# Intelligent shortcut for "docker run" that uses an identical image, hostname and container name
function dr() {
  docker run -d --hostname="${@: -1}" --name="${@: -1}" $@
}

# Intelligent shortcut for "docker build" that names the image after the working directory
function db() {
  pwd=`pwd`
  base=`basename $pwd`
  docker build -t $base .
}

# Useful docker integration for Mac/Windows systems
function boot2docker_init() {
	if [ -f /usr/local/bin/boot2docker ]
	then
	    exe=/usr/local/bin/boot2docker

	    ( $exe status | grep -q running ) || {
	      $exe init
	      $exe start
	    }
	  
	    if [ -z "$DOCKER_HOST" ]
	    then
	      $($exe shellinit)
	    fi
	fi
}

# Docker wrapper that provides some useful new commands and also integrates with boot2docker, if applicable.
function docker() {
	boot2docker_init
	real_docker=`which docker`

	if [ "$1" == "gc" ] # garbage-collect terminated containers
	then
	  for cont in `$real_docker ps -q -a --filter=[status=exited]`
	  do
	    $real_docker rm -f $cont
	  done
	elif [ "$1" == "gci" ] # garbage-collect unused images
	then
	   for img in `$real_docker images | grep '<none>' | cut -b 41-52` 
	   do
	     $real_docker rmi -f $img
	   done 
	elif [ "$1" == "shell" ] # open a bash session in a running container
	then
	  docker exec -t -i $2 /bin/bash
	elif [ "$1" == "it" ] # return the ID of the most recently created container
	then
	  echo `$real_docker ps | head -n 2 | tail -n 1 | cut -b 1-12`
	else
	  $real_docker $@
	fi
}
