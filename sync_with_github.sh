#!/bin/bash

function check_previous_sync_alive(){
  local script_name=$(basename $0)
  local sync_processes=$(ps -ef | grep $script_name) 
  local num_sync_processes=$(ps -ef | grep $script_name | wc -l) 

  if [ $num_sync_processes -ge 4 ]; then
    echo "true" 
  else
    echo "false"
  fi
}   

is_previous_sync_alive=`check_previous_sync_alive`

if [ "$is_previous_sync_alive" == "false" ] ; then
  exit 1
fi

git add -A .
git commit -m 'auto commit'
git pull --rebase
git push
