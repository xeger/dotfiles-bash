alias f="find . -iname"
alias ll="ls -l"
alias ups="ps aux | grep tony | grep -Ev '/(Library|System|Applications)'"

alias r="bundle exec rake"
alias bx="bundle exec"
alias bc="bundle console"

alias review="git diff --color=always --word-diff=color --inter-hunk-context=50"

function g {
  right_x="$HOME/Code/rightscale/right_$1"
  normal_x="$HOME/Code/rightscale/$1"
  xeger_x="$HOME/Code/xeger/$1"
  go_x="$HOME/Code/go/src/github.com/rightscale/$1"

  if [ -d $right_x ]; then
    cd $right_x
  elif [ -d $normal_x ]; then
    cd $normal_x
  elif [ -d $xeger_x ]; then
    cd $xeger_x
  elif [ -d $go_x ]; then
    cd $go_x
  else
    echo "Error: can't find $right_x, $xeger_x, $other_x or $go_x"
  fi
}

# see https://github.com/rightscale/right_site/tree/master/spec/spec_helper.rb
export FAST=1
