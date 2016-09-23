#!/bin/bash

isExistApp=`pgrep node`
if [[ -n  \$isExistApp ]]; then
   service node stop
fi

isExistApp=`pgrep nginx`
if [[ -n  \$isExistApp ]]; then
   service nginx stop
fi
