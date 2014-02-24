function abs_path {
  (cd "${1%/*}" &>/dev/null && printf "%s/%s" "$(pwd)" "${1##*/}")
}

function editify() {
  if [ "$1" == "--help" ] || [ -z "$1" ]
  then
    echo 'Usage: editify <--help|--list|--push|--pop|--reset|<gem name> [gem location]>'
    echo '--help shows this message'
    echo '--list any editified gems in project'
    echo '--push any editified gems by removing symlinks and keeping gem names'
    echo '--pop any editified gems by restoring symlinks using any updated SHAs'
    echo '--reset any editified gems by removing symlinks and forgetting gem names'
    echo '<gem name> toggles edifitication on/off for the gem in the bundler cache'
    echo '  location using either a relative source directory or the directory given.'
    return 0
  elif [ "$1" == "--list" ] || [ "$1" == "--push" ] || [ "$1" == "--pop" ] || [ "$1" == "--reset" ]
  then
    ruby ${BASH_SOURCE[0]/%editify.sh/lib/editify_helper.rb} $1
    return $?
  else
    if [ ! -f Gemfile ]
    then
      echo "No Gemfile in working directory."
      return 1
    fi

    gem_name=$1
    if [ $gem_name == '--' ]
    then
      # bundler will ignore -- and the CWD gets wacked as a result of editify.
      echo "Provide a valid gem name."
      gem_name=
      return 1
    fi
    `bundle show $gem_name 1>/dev/null 2>&1`
    if [ $? != 0 ]
    then
      echo "Gem $gem_name is unknown to Gemfile."
      gem_name=
      return 1
    fi

    bundled_gem_location=`bundle show $gem_name`

    if [ $? == 0 ]
    then
      echo "Found bundled $gem_name at $bundled_gem_location"
    else
      echo "Cannot determine bundled location of $gem_name; please verify that Bundler is happy"
      gem_name=
      bundled_gem_location=
      return 3
    fi

    if [ -L $bundled_gem_location ]
    then
      echo "Resetting $gem_name to Bundler default location"
      rm -f $bundled_gem_location
      bundle install
      if [ $? == 0 ]
      then
        echo "Reset editified gem $gem_name to gitted source."
        gem_name=
        bundled_gem_location=
        return 0
      fi
    else
      # resolve source directory for symlink.
      if [ -z "$2" ]
      then
        if [ -d ../../$gem_name ]
        then
          user_location=$(abs_path ../../$gem_name)
        elif [ -d ../$gem_name ]
        then
          user_location=$(abs_path ../$gem_name)
        else
          # clear in case previously set
          user_location=
        fi
      else
        user_location=$(abs_path $2)
      fi

      if [ $? == 0 ] && [ ! -z "$user_location" ] && [ -d $user_location ]
      then
        echo "Found local clone of $gem_name at $user_location"
      else
        echo "Cannot locate a local clone of $gem_name; try specifying it on the command line."
        gem_name=
        bundled_gem_location=
        user_location=
        return 2
      fi

      echo "Removing original $gem_name from $bundled_gem_location"
      rm -Rf $bundled_gem_location
      echo "Pointing Bundler to the local-disk version of $gem_name at $user_location"
      ln -sf $user_location $bundled_gem_location
      if [ $? == 0 ]
      then
        echo "Editified gem $gem_name to $user_location"
        echo
        echo "WARNING: bundle update will perform a hard reset on editified gitted gem"
        echo "directories and it will do this for all gitted gems regardless of which gems"
        echo "you specify for bundle update. It is important to either save your changes"
        echo "to the gitted gem directory before performingbundle update or else to use"
        echo "editify --push/--pop before/after the bundle update."
        gem_name=
        bundled_gem_location=
        user_location=
        return 0
      fi
    fi

    echo "Not so happy. Where did we go wrong?"
    gem_name=
    bundled_gem_location=
    user_location=
    return 4
  fi
}
