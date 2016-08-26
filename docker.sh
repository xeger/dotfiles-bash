
function docker-find-container() {
  running=`docker ps --format '{{.Names}}'`
  declare -a matches

  for c in $running; do
    if [[ $c == *"$1"* ]]; then
      matches=("${matches[@]}" "$c")
    fi
  done
  echo ${matches[@]}
  if [ ${#matches[@]} -gt 1 ]; then
    return 1 
  else
    return 0
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
    docker exec -t -i $target /bin/bash --login
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
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias di="docker images"
alias dgc="docker-gc"
alias dsh="docker-shell"
alias cmdb="docker run -t -i --net=host rightscale/cmdb:latest"

