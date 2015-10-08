# Tell Ruby never to print deprecation warnings; they're useless to us.
export RUBYOPT=-W0

if [ -d $HOME/.rbenv/bin ]
then
  export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
fi

function use() {
  if [ -z "$1" ]; then
    rbenv versions
  elif [ "$1" == "local" ]; then
    echo "Reverting to normal rbenv behavior (local/global based on .ruby_version)"
    unset RBENV_VERSION
  elif [ "$1" == "global" ]; then
    global_ver=`cat ~/.rbenv/version`
    echo "Switching Ruby version to $global_ver"
    if [ -f .ruby_version]; then
      echo "WARNING: this overrides project-specific settings found in .ruby-version, 'use local' to undo"
    fi
    export RBENV_VERSION="$global_ver"
  else
    local pattern="^$1"
    local found=""
    local available_versions=`rbenv versions --bare`
    available_versions="system $available_versions" # omitted by --bare

    for installed_version in $available_versions; do
      if [[ $installed_version =~ $pattern ]]; then
        found="$installed_version"
      fi
    done

    if [ -n "$found" ]; then
      echo "Switching Ruby version to to $found"
      if [ -f .ruby_version ]; then
        echo "WARNING: this overrides project-specific settings found in .ruby-version, 'use local' to undo"
      fi
      export RBENV_VERSION="$found"
    else
      echo "Cannot find an rbenv version whose name begins with $1"
      echo "Try 'rbenv versions' to see which versions are available"
      return 1
    fi
  fi
}

