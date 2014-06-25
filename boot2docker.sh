which -s boot2docker && {
  boot2docker init
  boot2docker start
  export DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375
}
