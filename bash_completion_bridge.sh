#!/bin/bash
# $0 = name of this script
# $1 = bash completion script to evaluate
# $2 = all words in current command (COMP_WORDS)
# $3 = current command line (COMP_LINE)
# $4 = cursor position (COMP_POINT)
# $5 = word being completed (parameter to completion function)
# $6 = word before current word being completed (parameter to completion function)

# This will run a line something like...
# complete -o default -F __start_kubectl kubectl
source $1

# Locate the completion function for the command.
# completionfunc will be __start_kubectl
IFS=':' read -r -a COMP_WORDS <<< "$2"
for index in "${!COMP_WORDS[@]}"; do COMP_WORDS[$index]=$(printf '%b' "${COMP_WORDS[$index]//%/\\x}"); done
export COMP_WORDS
command=${COMP_WORDS[0]}
expression=".*?-F \K([a-zA-Z0-9_]+)(?= .*$command)"
completionfunc=$(complete -p | grep -oP -e "$expression")

# https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html
# $COMP_LINE = The current command line.
# $COMP_POINT = The index of the current cursor position relative to the beginning of the current command. If the current cursor position is at the end of the current command, the value of this variable is equal to ${#COMP_LINE}.
# $COMP_KEY = The key (or final key of a key sequence) used to invoke the current completion function. 9 = TAB
# $COMP_TYPE = Set to an integer value corresponding to the type of completion attempted that caused a completion function to be called: TAB (9), for normal completion, ‘?’, for listing completions after successive tabs, ‘!’, for listing alternatives on partial word completion, ‘@’, to list completions if the word is not unmodified, or ‘%’, for menu completion.
# Invoke the located function with
# - The name of the command whose arguments are being completed
# - The word being completed
# - The word preceding the word being completed
COMP_LINE=$3
export COMP_LINE
COMP_POINT=$4
export COMP_POINT
COMP_KEY=9
export COMP_KEY
COMP_TYPE=9
export COMP_TYPE
fullcompcall="$completionfunc \"$command\" \"$5\" \"$6\""
eval $fullcompcall