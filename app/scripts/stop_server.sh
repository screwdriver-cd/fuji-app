#!/bin/bash

isExistApp=`pgrep node`
if [[ -n  \$isExistApp ]]; then
   kill $isExistApp
fi

isExistApp=`pgrep nginx`
if [[ -n  \$isExistApp ]]; then
   service nginx stop
fi
