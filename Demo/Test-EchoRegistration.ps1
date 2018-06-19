# This registers (or re-registers) completions for kubectl
# as exported to "kubectl_completions.sh"
Import-Module ..\PSBashCompletions -Force
Register-BashArgumentCompleter echotest "$PSScriptRoot\echotest_completions.sh" -Verbose