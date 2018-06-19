# This registers (or re-registers) completions for kubectl
# as exported to "kubectl_completions.sh"
Import-Module ..\PSBashCompletions -Force
Register-BashArgumentCompleter kubectl "$PSScriptRoot\kubectl_completions.sh" -Verbose