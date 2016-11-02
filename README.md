dotfiles
========

Tony Spataro's shared bash profile directory.

Install / Usage
===============

First, fork this repository to make it your own.

Next, clone your fork onto the machine where you want to use the dotfiles.
I generally clone it directly into a hidden directory under my home.

    $ git clone git@github.com:xeger/dotfiles-bash ~/.bash_profile.shared
  
Finally, setup your main .bash_profile so it will pull in all of these files.
If you have any system-local dotfiles, you can store those under ~/.bash_profile.d
as per the standard.

Example .bash_profile
---------------------

    source ~/.bashrc

    for script in $HOME/.bash_profile.d/*.sh ; do
        if [ -r $script ] ; then
            . $script
        fi
    done

    for script in $HOME/.bash_profile.shared/*.sh; do
        if [ -r $script ] ; then
            . $script
        fi
    done


  
