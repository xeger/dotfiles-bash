alias dit="docker it"
alias dk="docker rm -f \`docker it\`"
alias drm="docker rm -f"
alias drmi="docker rmi"
alias dps="docker ps"
alias di="docker images"
alias dgc="docker gc ; docker gci"
alias dsh="docker shell"

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
          targets=(`$real_docker ps -a -q -f status=exited`)
          num_targets=${#targets[@]}
	  echo "Removing $num_targets terminated containers:"
	  [ -n "$targets" ] && $real_docker rm -v ${targets[@]}
	elif [ "$1" == "gci" ] # garbage-collect unused images
	then
	  targets=(`$real_docker images -q -f dangling=true`)
          num_targets=${#targets[@]}
	  echo "Removing $num_targets dangling images:"
	  [ -n "$targets" ] && $real_docker rmi ${targets[@]}
	elif [ "$1" == "shell" ] # open a bash session in a running container
	then
	  docker exec -t -i $2 /bin/bash
	elif [ "$1" == "it" ] # return the ID of the most recently created container
	then
	  echo `$real_docker ps -a | head -n 2 | tail -n 1 | awk '{print $NF}'`
	else
	  $real_docker $@
	fi
}
