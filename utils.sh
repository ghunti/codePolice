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


# Finds the changed lines of a file with the diff program
# Returns all changed lines separated by a space (so they can be turned into an array)
#
# @param Previous file version
# @param Current file version
#
# @return All changed lines number separated by a space
function getChangedLines()
{
    local prevVersion=$1
    local currVersion=$2
    local tempLines=$(diff $prevVersion  $currVersion \
        --old-group-format='%dE|' \
        --new-group-format='%dF%(F=L?:,%dL)|' \
        --changed-group-format='%dF%(F=L?:,%dL)|' \
        --unchanged-group-format="" \
        | tr "|" "\n")

    local lines=()
    for line in $tempLines
    do
        echo "$line" | grep ',' &> /dev/null
        if [ $? != 0 ]
        then
            lines=("${lines[@]}" $line)
        else
            local min=$(echo "$line" | cut -f1 -d,)
            local max=$(echo "$line" | cut -f2 -d,)
            while [ $min -le $max ]
            do
                lines=("${lines[@]}" $min)
                min=$(( $min + 1 ))
            done
        fi
    done

    echo "${lines[@]}"
}

# Checks if a value is present on the array
#
# @param The value to look for
# @param The array where to search the value
# @return 0 if the value is found, 1 otherwise
function isInArray()
{
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}


#Auto-execute this code when the script is included on other scripts
includeConfig
#Use HEAD if available, otherwise use the empty tree object
HEAD=$(git rev-parse --verify HEAD 2> /dev/null || echo 4b825dc642cb6eb9a060e54bf8d69288fbee4904)