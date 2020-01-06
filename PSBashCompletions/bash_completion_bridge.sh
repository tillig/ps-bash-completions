#!/bin/bash
# $0 = name of this script
# $1 = bash completion script to evaluate
# $2 = full command line so far, URL encoded
# Assumption: Completion is happening at the END of the current command line.

# Bring in the completion script.
source "$1"

# URL decode the command line to evaluate.
line=$(printf '%b' "${2//%/\\x}")

# Slightly modified version of
# https://brbsix.github.io/2015/11/29/accessing-tab-completion-programmatically-in-bash/
get_completions(){
    # https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html#Bash-Variables
    local completion COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMPREPLY=()

    # Load bash-completion if necessary
    declare -F _completion_loader &>/dev/null || {
        script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        source "$script_dir/bash_completion.sh"
    }

    # COMP_KEY - Key used to invoke the completion (TAB)
    COMP_KEY=9

    # COMP TYPE - Type of completion to generate
    #   TAB (9) = normal completion
    #   ? (63) = listing completions after successive tabs
    #   ! (33) = listing alternatives on partial word completion
    #   @ (64) = list completions if the word is not unmodified
    #   % (37) = menu completion
    COMP_TYPE=9

    # COMP_LINE - The current command line
    COMP_LINE=$*

    # COMP_POINT - The index of the cursor relative to the beginning of the line.
    COMP_POINT=${#COMP_LINE}

    eval set -- "$@"

    # COMP_WORDS - Array with the individual words from the current line.
    COMP_WORDS=("$@")

    # Add '' to COMP_WORDS if the last character of the command line is a space.
    [[ ${COMP_LINE[@]: -1} = ' ' ]] && COMP_WORDS+=('')

    # COMP_CWORD - Index of word where the cursor is.
    COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

    # Determine completion function.
    completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')

    # Run _completion_loader only if necessary. Shouldn't have to
    # since we loaded it at the top of the script.
    [[ -n $completion ]] || {
        # Load and detect completion.
        _completion_loader "$1"
        completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')
    }

    # Ensure completion was detected.
    [[ -n $completion ]] || return 1

    # Calculate the previous word to pass to the completion function.
    prevWord=""
    if [ "$COMP_CWORD" -ge "1" ]; then
        prevWord="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Invoke completion function with parameters as specified
    # https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html
    # - Name of command being completed
    # - Word being completed
    # - Word preceding the word being completed
    eval "$completion \"$COMP_WORDS\" \"${COMP_WORDS[COMP_CWORD]}\" \"$prevWord\""

    # Print completions to stdout.
    printf '%s\n' "${COMPREPLY[@]}" | LC_ALL=C sort
}

get_completions $line
