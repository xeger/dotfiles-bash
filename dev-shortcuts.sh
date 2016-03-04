alias f="find . -iname"
alias ll="ls -l"
alias ups="ps aux | grep tony | grep -Ev '/(Library|System|Applications)'"

alias r="bundle exec rake"
alias bx="bundle exec"
alias bc="bundle console"

alias review="git diff --color=always --word-diff=color --inter-hunk-context=50"

function g() {
  bases="$HOME/Code/rightscale $HOME/Code/xeger $HOME/Code/go/src/github.com/rightscale"
  regexp=`echo "^$1" | sed -e 's/[A-Za-z]/&[^_]*_/g' | sed -e 's/_$//'`

  for base in $bases
  do
    candidates=`ls -d $base/*`
    for candidate in $candidates
    do
      bn=`basename $candidate`
      if [ $bn == $1 ]
      then
        cd $candidate
        return 0
      elif [[ $bn =~ $regexp ]]
      then
        cd $candidate
        return 0
      fi
    done
  done

  echo "Could not find a directory matching '$1' under any of:"
  for base in $bases
  do
    echo "  $base"
  done
}

# see https://github.com/rightscale/right_site/tree/master/spec/spec_helper.rb
export FAST=1
