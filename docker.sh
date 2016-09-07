
function docker-find-container() {
  running=`docker ps --format '{{.Names}}'`
  declare -a matches

  for c in $running; do
    if [[ $c == $1 ]]; then
      # exact full-string match: print container name and exit early
      echo $c
      return 0
    elif [[ $c == *"$1"* ]]; then
      # record partial match
      matches=("${matches[@]}" "$c")
    fi
  done

  if [ ${#matches[@]} -eq 1 ]; then
    # exactly one match: print full container name
    echo ${matches[@]}
    return 0
  elif [ ${#matches[@]} -eq 0 ]; then
    # no matches: print $1 verbatim
    echo $1
    return 0
  else
    # many matches (ambiguous): print all matching containers and fail
    echo ${matches[@]}
    return 1
  fi
}

function docker-it() {
  echo `docker ps -a | head -n 2 | tail -n 1 | awk '{print $NF}'`
}

function docker-gc() {
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc spotify/docker-gc
}

function docker-shell() {
  target=`docker-find-container $1`
  if [ $? == 0 ]; then
    docker exec -t -i -u root $target /bin/bash --login
  else
    echo "Too many matching container names; please be more specific to choose one of:"
    echo "  $target"
  fi
}

alias dc="docker-compose"
alias dm="docker-machine"

alias dit="docker-it"
alias drm="docker rm -f"
alias drmi="docker rmi"
alias dps="docker ps --format 'table {{.ID | printf \"%12.12s\"}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias di="docker images"
alias dgc="docker-gc"
alias dsh="docker-shell"
alias cmdb="docker run -t -i --net=host rightscale/cmdb:latest"
