#!/bin/bash
cd /home/master
curl https://gist.githubusercontent.com/cloudways-haider/f7cb6627f6674c263624589d360e12b4/raw/9d0b2c78ace5b7b2dedb411e9d676129e34b470a/nvm_install.sh | bash
export NVM_DIR="$HOME/.nvm"   # This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install node
