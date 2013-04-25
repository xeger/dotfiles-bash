alias f="find . -iname"
alias ll="ls -l"
alias ups="ps aux | grep tony | grep -Ev '/(Library|System|Applications)'"

alias r="bundle exec rake"
alias bx="bundle exec"

alias review="git diff --color=always --word-diff=color --inter-hunk-context=50"

function g {
  right_x="$HOME/Code/RightScale/right_$1"
  normal_x="$HOME/Code/RightScale/$1"
  other_x="$HOME/Code/Other/$1"

  if [ -d $right_x ]; then
    cd $right_x
  elif [ -d $normal_x ]; then
    cd $normal_x
  elif [ -d $other_x ]; then
    cd $other_x
  else
    echo "Error: can't find $right_x or $normal_x or $other_x"
  fi
}
