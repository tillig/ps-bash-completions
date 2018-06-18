# Completion test/echo script from
# https://blog.bouzekri.net/2017-01-28-custom-bash-autocomplete-script.html

_echotest() {
  COMPREPLY=()

  echo ""
  echo "COMP_WORDS : ${COMP_WORDS}"
  echo "COMP_CWORD : ${COMP_CWORD}"
  echo "COMP_WORDS[COMP_CWORD] : ${COMP_WORDS[COMP_CWORD]}"
  echo "COMP_LINE : ${COMP_LINE}"
  echo "COMP_POINT : ${COMP_POINT}"
  echo "COMP_KEY : ${COMP_KEY}"
  echo "COMP_TYPE : ${COMP_TYPE}"
  echo "args : $@"
  echo "reply : ${COMPREPLY}"
}

complete -F _echotest echotest
