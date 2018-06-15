[CmdletBinding()]
param(
  [Parameter(Mandatory=$True, Position=0)]
  [ValidateNotNullOrEmpty()]
  [string]
  $Command,

  [Parameter(Mandatory=$True, Position=1)]
  [ValidateScript({if(-Not($_ | Test-Path -PathType Leaf)){ throw "The completion file was not found." } return $true})]
  [ValidateNotNull()]
  [System.IO.FileInfo]
  $BashCompletions,

  [ValidateScript({if(-Not($_ | Test-Path -PathType Leaf)){ throw "The bridge script file was not found." } return $true})]
  [ValidateNotNull()]
  [System.IO.FileInfo]
  $BridgeScript = "$PSScriptRoot\bash_completion_bridge.sh"
)

Write-Verbose "Starting command completion registration for $Command"
$BashCompletionPath = "$($BashCompletions.FullName)"
Write-Verbose "Bash completions for $Command = $BashCompletionPath"

# Locate bash
$bash = Get-Command bash -ErrorAction Ignore
if($bash -eq $Null) {
  Write-Verbose "bash is not in the path."

  # Try for bash packaged with Git for Windows
  $git = Get-Command git -ErrorAction Ignore
  if($git -eq $Null) {
    Write-Error "Unable to locate bash."
    Exit 1
  }

  $bash = [System.IO.Path]::Combine([System.IO.DirectoryInfo]::new([System.IO.Path]::GetDirectoryName((Get-command git).Source)).Parent.FullName, "bin", "bash.exe")
  if(-not (Test-Path $bash)) {
    Write-Error "Unable to locate bash."
    Exit 1
  }

  Write-Verbose "Found bash packaged with git."
} else {
  Write-Verbose "Found bash in path."
  $bash = $bash.Source
}

Write-Verbose "bash: $bash"

$BridgeScript = [System.IO.Path]::GetFullPath($BridgeScript)
Write-Verbose "Completion bridge = $BridgeScript"

$block = {
  param($partialWordToComplete, $commandSoFar, $cursorPosition)
  $val = "{ $partialWordToComplete / $commandSoFar / $cursorPosition }"

  # Run bash to get the completion
  $words = [System.Text.RegularExpressions.Regex]::Matches("$commandSoFar", "(?<=`")[^`"]*(?=`")|[^`" ]+")
  if ($words.Count -lt 2) {
    # We want the word _before_ this one. There is only one word.
    $previousWord = ""
  } else {
    $previousWord = $words[$words.Count - 2].Value
  }
  #$result = (&"$bash" -l -c "$BridgeScript" "$BashCompletionPath" "$Command" "$commandSoFar" "$cursorPosition" "$partialWordToComplete" "$previousWord")
  $result = "`"$bash`" -l -c `"$BridgeScript`" `"$BashCompletionPath`" `"$Command`" `"$commandSoFar`" `"$cursorPosition`" `"$partialWordToComplete`" `"$previousWord`""

  # CompletionResult https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.completionresult.-ctor?view=powershellsdk-1.1.0#System_Management_Automation_CompletionResult__ctor_System_String_System_String_System_Management_Automation_CompletionResultType_System_String_
  # string - the text used as the auto completion result
  # string - the text to be displayed in a list
  # CompletionResultType https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.completionresulttype?view=powershellsdk-1.1.0
  # string the text for the tooltip with details
  [System.Management.Automation.CompletionResult]::new($result, $result, 'Text', $result)
}.GetNewClosure()

Register-ArgumentCompleter -Native -CommandName $Command -ScriptBlock $block
