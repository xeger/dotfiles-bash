# adds color and formatting parameters to a command shell shortcut.
# also allows for specifying a partial search pattern without having to type
# full path to _spec.rb
function rspek() {
  if [ -z $1 ]
  then
    echo "Usage: rspek <full or partial spec name>"
    echo "Examples:"
    echo "  rspek spec/foos/foo_spec.rb"
    echo "  rspek foo"
    return 1
  fi
  rspec_pattern=$1
  if [ ! -f $rspec_pattern ]
  then
    # user may be referring to a deep _spec.rb file.
    rspec_pattern="spec/**/$1_spec.rb"
  fi
  rspec_cmd="bundle exec rspec --color -f documentation -P $rspec_pattern"
  echo $rspec_cmd
  $rspec_cmd
  rspec_cmd=
  rspec_pattern=
}
