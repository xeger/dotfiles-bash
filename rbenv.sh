# Never bother with Tcl/Tk support when building Rubies
export RUBY_CONFIGURE_OPTS="--without-tk --without-tcl --with-out-ext=tcl --with-out-ext=tk"

# Tell Ruby never to print deprecation warnings; they're useless to us.
export RUBYOPT=-W0

# With OS X, make sure that C compilers find XCode headers and lib dirs.
#
# Prerequisites: XCode 5.x is installed and you have run the "xcode-select --install" command from
# Terminal.
#
# This is necessary with XCode 5.0 and above because headers and libs are no longer installed under
# /usr.
which -s xcrun
if [ $? == 0 ]; then
  export CPPFLAGS="$CPPFLAGS -I$(xcrun --show-sdk-path)/usr/include"
  export CFLAGS="$CFLAGS -I$(xcrun --show-sdk-path)/usr/include -L$(xcrun --show-sdk-path)/usr/lib"
fi

# With Homebrew
#
# Prerequisites: the following homebrew packages have been installed and, if necessary, force-linked
# using "brew link -f":
#     apple-gcc42
#     openssl
#     readline
#     zlib
#
# This is necessary on Mac OS X Lion (10.8) and above because some Unix libraries no longer ship with
# the OS.
which -s brew
apple_gcc42="$(brew --prefix)/bin/gcc-4.2"
if [ -f "$apple_gcc42" ]; then
  export CC=$apple_gcc42
  export RUBY_CONFIGURE_OPTS="$RUBY_CONFIGURE_OPTS --with-readline-dir=$(brew --prefix readline) --with-openssl-dir=$(brew --prefix openssl)"
  export CPPFLAGS="-I$(brew --prefix)/include -L$(brew --prefix)/lib"
  export CFLAGS=$CPPFLAGS
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

