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
$bashCompletionScript = "/$([System.IO.Path]::GetFullPath($BashCompletions.FullName).Replace('\', '/').Replace(':', ''))"
Write-Verbose "Bash completions for $Command = $bashCompletionScript"

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

$bashBridgeScript = [System.IO.Path]::GetFullPath($BridgeScript)
Write-Verbose "Completion bridge = $bashBridgeScript"

$block = {
  param($partialWordToComplete, $commandSoFar, $cursorPosition)
  Add-Type -Assembly System.Web
  $val = "{ $partialWordToComplete / $commandSoFar / $cursorPosition }"

  # Run bash to get the completion
  $words = [System.Text.RegularExpressions.Regex]::Matches("$commandSoFar", "(?<=`")[^`"]*(?=`")|[^`" ]+")
  if ($words.Count -lt 2) {
    # We want the word _before_ this one. There is only one word.
    $previousWord = ""
  } else {
    $previousWord = $words[$words.Count - 2].Value
  }

  # Pass the array as a colon-delimited URL-encoded string to ensure quoted items and spaces are properly passed.
  # Colon will get encoded if it's part of the value so colon as delimiter is safe after encoding each item.
  # @("`"a`"", "`"b`"", "`"c`"")
  # becomes
  # %22a%22:%22b%22:%22c%22
  # and the bridge script can parse/decode that back into an array.
  $COMP_WORDS = [String]::Join(':', ($words | %{[System.Web.HttpUtility]::UrlEncode($_).Replace('+','%20')}))
  $COMP_LINE = $commandSoFar
  $COMP_POINT = $cursorPosition

  # TODO: Calculate COMP_CWORD (the index of the word in COMP_WORDS the current cursor is on)
  #$result = (&"$bash" "$bashBridgeScript" "$bashCompletionScript" "$COMP_WORDS" "$COMP_LINE" "$COMP_POINT" "$partialWordToComplete" "$previousWord")
  $result = "`"$bash`" `"$bashBridgeScript`" `"$bashCompletionScript`" `"$COMP_WORDS`" `"$COMP_LINE`" `"$COMP_POINT`" `"$partialWordToComplete`" `"$previousWord`""

  # CompletionResult https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.completionresult.-ctor?view=powershellsdk-1.1.0#System_Management_Automation_CompletionResult__ctor_System_String_System_String_System_Management_Automation_CompletionResultType_System_String_
  # string - the text used as the auto completion result
  # string - the text to be displayed in a list
  # CompletionResultType https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.completionresulttype?view=powershellsdk-1.1.0
  # string the text for the tooltip with details
  [System.Management.Automation.CompletionResult]::new($result, $result, 'Text', $result)
}.GetNewClosure()

Register-ArgumentCompleter -Native -CommandName $Command -ScriptBlock $block
