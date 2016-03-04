function docker-it() {
  echo `docker ps -a | head -n 2 | tail -n 1 | awk '{print $NF}'`
}

function docker-gc() {
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc spotify/docker-gc
}

function docker-shell() {
  docker exec -t -i $1 /bin/bash --login
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
