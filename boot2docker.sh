function boot2docker() {
  exe=/usr/local/bin/boot2docker

  ( $exe status | grep -q running ) || {
    set -e
    $exe init
    $exe start
    export DOCKER_HOST=tcp://$($exe ip 2>/dev/null):2375
  }

  $exe $@
}

