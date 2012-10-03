#!/bin/bash

#Include the general configuration
function includeConfig() {
	script_path=$(dirname $(readlink -f $0))
	config_file="$script_path/githooks.config"
	if [ -f "$config_file" ]; then
	    source "$config_file"
	else
	    printf "Unable to find config file '%s'\n" "$config_file"
	    exit 1
	fi
}

#Check if a regex exists on the code that's about
#to be commited (staged)
function checkForRegexCodeOnStage()
{
    local regex=$1
    OLDIFS=$IFS
    IFS='\n'
    lastCommandResult=$(git diff --staged | egrep -ni "$regex")
    IFS=$OLDIFS
}


#Auto-execute this code when the script is included on other scripts
includeConfig
#Use HEAD if available, otherwise use the empty tree object
HEAD=$(git rev-parse --verify HEAD 2> /dev/null || echo 4b825dc642cb6eb9a060e54bf8d69288fbee4904)
