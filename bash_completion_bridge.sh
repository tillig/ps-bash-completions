#!/bin/bash
# $0 = name of this script
# $1 = bash completion script to evaluate
# $2 = full command line so far, URL encoded

# This will run a line something like...
# complete -o default -F __start_kubectl kubectl
source $1
line=$(printf '%b' "${2//%/\\x}")

get_completions(){
    # Slightly modified version of
    # https://brbsix.github.io/2015/11/29/accessing-tab-completion-programmatically-in-bash/
    local completion COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMPREPLY=()

    # load bash-completion if necessary
    declare -F _completion_loader &>/dev/null || {
        script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        source "$script_dir/bash_completion.sh"
    }

    COMP_KEY=9
    COMP_TYPE=9
    COMP_LINE=$*
    COMP_POINT=${#COMP_LINE}

    eval set -- "$@"

    COMP_WORDS=("$@")

    # add '' to COMP_WORDS if the last character of the command line is a space
    [[ ${COMP_LINE[@]: -1} = ' ' ]] && COMP_WORDS+=('')

    # index of the last word
    COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

    # determine completion function
    completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')

    # run _completion_loader only if necessary
    [[ -n $completion ]] || {

        # load completion
        _completion_loader "$1"

        # detect completion
        completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')

    }

    # ensure completion was detected
    [[ -n $completion ]] || return 1

    prevWord=""
    if [ "$COMP_CWORD" -ge "1" ]; then
        prevWord="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # execute completion function
    eval "$completion \"$COMP_WORDS\" \"${COMP_WORDS[COMP_CWORD]}\" \"$prevWord\""

    # print completions to stdout
    printf '%s\n' "${COMPREPLY[@]}" | LC_ALL=C sort
}

get_completions $line