#!/bin/bash
# $0 = name of this script
# $1 = bash completion script to evaluate
# $2 = root command name
# $3 = current command line (COMP_LINE)
# $4 = cursor position (COMP_POINT)
# $5 = word being completed
# $6 = word before current word being completed

# Bash completion adds this function, quick test to see if it's available
# and bail if not.
if ! type _get_comp_words_by_ref >/dev/null 2>&1; then
  echo 'Completion is not set up on your bash shell. Check your .bashrc.'
  exit
fi

# This will run a line something like...
# complete -o default -F __start_kubectl kubectl
source $1

# Locate the completion function for the command.
# completionfunc will be __start_kubectl
expression=".*?-F \K([a-zA-Z0-9_]+)(?= .*$2)"
completionfunc=$(complete -p | grep -oP -e "$expression")

# https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html
# $COMP_LINE = The current command line.
# $COMP_POINT = The index of the current cursor position relative to the beginning of the current command. If the current cursor position is at the end of the current command, the value of this variable is equal to ${#COMP_LINE}.
# $COMP_KEY = The key (or final key of a key sequence) used to invoke the current completion function.
# $COMP_TYPE = Set to an integer value corresponding to the type of completion attempted that caused a completion function to be called: TAB, for normal completion, ‘?’, for listing completions after successive tabs, ‘!’, for listing alternatives on partial word completion, ‘@’, to list completions if the word is not unmodified, or ‘%’, for menu completion.
# Invoke the located function with
# - The name of the command whose arguments are being completed
# - The word being completed
# - The word preceding the word being completed
# https://blog.bouzekri.net/2017-01-28-custom-bash-autocomplete-script.html
COMP_LINE=$3
export COMP_LINE
COMP_POINT=$4
export COMP_POINT
COMP_KEY=9
export COMP_KEY
COMP_TYPE=9
export COMP_TYPE
fullcompcall="$completionfunc \"$2\" \"$5\" \"$6\""
eval $fullcompcall