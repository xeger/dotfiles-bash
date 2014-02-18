function abs_path {
  (cd "${1%/*}" &>/dev/null && printf "%s/%s" "$(pwd)" "${1##*/}")
}

function editify() {
	gem_name=$1

	if [ -d ../../$gem_name ]
	then
		gem_location=$(abs_path ../../$gem_name)
	elif [ -d ../$gem_name ]
	then
		gem_location=$(abs_path ../$gem_name)
	fi

	if [ $? == 0 ]
	then
		echo "Found local clone of $gem_name at $gem_location"
	else
		echo "Cannot find absolute path to a suitable local clone of $gem_name"
		return -1
	fi

	bundled_gem_location=`bundle show $gem_name`
	
	if [ $? == 0 ]
	then
		echo "Found bundled $gem_name at $bundled_gem_location"
	else
		echo "Cannot determine bundled location of $gem_name; please verify that Bundler is happy"
		return -2
	fi

	if [ -L $bundled_gem_location ]
	then
		echo "Resetting $gem_name to Bundler default location"
		rm -f $bundled_gem_location
		bundle install
	else
		echo "Removing original $gem_name from $bundled_gem_location"
		rm -Rf $bundled_gem_location
		echo "Pointing Bundler to the local-disk version of $gem_name"
		ln -sf $gem_location $bundled_gem_location
	fi

	if [ $? == 0 ]
	then
		echo "Good to go."
		return 0
	else
		echo "Not so happy. Where did we go wrong?"
		return -3
	fi
}
