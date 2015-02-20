# Dummy Git completion, so other profile snippets can call it when unavailable
function __git_complete() {
  return
}

# Dummy Git prompt, so other profile bits can call it when unavailable
function __git_ps1() {
  return 
}

# Enable git prompt integration unless specifically told not to.
# It helps to disable this stuff when you're working with network filesystems
# (git performs terribly over a network).
if [ -z "$GIT_PROMPT_DISABLE" ]
then
  # Load real Git completion
  for file in /usr/local/git/contrib/completion/git-completion.bash /usr/share/bash-completion/completions/git /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
  do
    [ -f $file ] && . $file
  done

  # Load real Git prompt
  for file in /usr/local/git/contrib/completion/git-prompt.sh /etc/bash_completion.d/git-prompt /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
  do
    [ -f $file ] && . $file
  done
fi

__git_complete gco _git_checkout
__git_complete merge _git_merge
__git_complete track _git_branch

# Define some useful command shortcuts. 
alias gco="git checkout"
alias ga="git add"
alias gl="git log --topo-order --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glt="git log --topo-order --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gsw="git show --color"
alias gd="git diff"
alias gdc="git diff --cached"
alias gb="git branch"
alias gcp="git cherry-pick"
alias gr="git rebase"
alias gss="git status"
alias gpl="git pull --ff-only"
alias gf="git fetch"
alias gsmu="git submodule update --init --recursive"

alias co="echo Use 'gco', you ninny!"

alias slist="git stash list"
alias spush="git stash save"
alias spop="git stash pop"
alias sapply="git stash apply"

alias fetch="git fetch"
alias merge="git merge --no-ff --no-commit"

# Push the working branch to master. 
function push {
  if [ -z $1 ]; then
    local h="$(git symbolic-ref HEAD 2>/dev/null)"
    local b=${h##refs/heads/}
  else
    local b=$1
  fi

  #read -p "Push $b to origin/$b? [y/N] " assent

  #if [ "$assent" == "y" ]; then
    git push origin $b
  #fi
}

# With no arguments, pull from origin.
#
# With two arguments where the first is "into," open a browser to create a GitHub
# pull request into the branch named in the second argument.
#
# Example:
#   pull into master
function pull {
  if [ "$1" == "into" ]; then
    local upstream=`git remote -v | grep push | sed 's|^.*github.com:\(.*\)\.git.*$|\1|'`
    local repo=`basename $PWD`
    local h="$(git symbolic-ref HEAD 2>/dev/null)"
    local source=${h##refs/heads/}
    local dest=$2
    local url="https://github.com/${upstream}/pull/new/${dest}...$source"
    open $url
  elif [ "$1" == "" ]; then
    git pull --ff-only
  else
    echo "Don't know how to $1"
    return 1
  fi
}

# Track a remote branch of the same name, at the given remote.
#
# Example:
#  track origin 
function track {
  local h="$(git symbolic-ref HEAD 2>/dev/null)"
  local b=${h##refs/heads/}

  if [ -z $1 ]; then
    local remote=origin
  else
    local remote=$1
  fi 

  git branch $b --set-upstream-to=$remote/$b
}

