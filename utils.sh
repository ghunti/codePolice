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


#Auto-execute this code when the script is included on other scripts
includeConfig
