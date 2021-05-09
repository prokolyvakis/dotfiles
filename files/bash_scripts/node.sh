# This loads nvm
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
# This loads nvm bash_completion
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"
# Change install location to prevent deletion of files upon upgrade
export NVM_DIR="$HOME/.nvm"