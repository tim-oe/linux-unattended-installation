alias cls='printf "\033c"'
alias agent='ssh-add ~/.ssh/id_rsa'
alias version='sudo lsb_release -a'
alias vmclean='sudo apt autoremove --purge'
alias dockerclean='docker system prune -a'
alias gitclean='git fetch; git reflog expire --expire=now --all; git gc --prune=now; git remote prune origin; git fsck --full'
