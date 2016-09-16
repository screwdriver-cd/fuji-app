#!/bin/bash
# isExistApp=`pgrep fuji-app-production`
# if [[ -n  \$isExistApp ]]; then
#    service fuji-app-production stop
# fi


isExistApp=`pgrep nginx`
if [[ -n  \$isExistApp ]]; then
   service nginx stop
fi
