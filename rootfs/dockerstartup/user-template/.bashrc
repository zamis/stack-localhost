source $STARTUPDIR/generate_container_user

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:/home/kasm-user/bin:/home/kasm-user/.dotnet/tools
export DOTNET_ROOT=/mnt/user-data/!apps/dotnet

$STARTUP_EXEC
