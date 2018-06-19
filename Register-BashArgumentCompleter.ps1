<#
.SYNOPSIS
  Registers command line completions from bash into PowerShell.

.DESCRIPTION
  Registers a command line completion that runs in bash so it can be brought into PowerShell. This
  is helpful for some commands like "kubectl" that have bash completions supported but where there
  is no built-in support for PowerShell.

  The command assumes you either have bash in your path or Git for Windows installed. If you don't
  have bash in the path then the version packaged with Git for Windows will be used.

.PARAMETER Command
  The name of the command in bash that needs completions in PowerShell (e.g., kubectl). This is what
  PowerShell will get completions on.

.PARAMETER BashCompletions
  The full path to the bash completion script that generates completions for the command. You can usually
  download this or export it from the command itself.
#>
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
  $BashCompletions
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

Write-Verbose "bash = $bash"

$bashBridgeScript = [System.IO.Path]::GetFullPath("$PSScriptRoot\bash_completion_bridge.sh")
Write-Verbose "Completion bridge = $bashBridgeScript"
Write-Verbose "Completion command = &`"$bash`" `"$bashBridgeScript`" `"$bashCompletionScript`" `"<url-encoded-command-line>`""

$block = {
  param($partialWordToComplete, $commandSoFar, $cursorPosition)

  Add-Type -Assembly System.Web
  $encodedCommand = [System.Web.HttpUtility]::UrlEncode($commandSoFar).Replace('+',"%20")
  $result = (&"$bash" "$bashBridgeScript" "$bashCompletionScript" "$encodedCommand")

  # CompletionResult https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.completionresult.-ctor?view=powershellsdk-1.1.0#System_Management_Automation_CompletionResult__ctor_System_String_System_String_System_Management_Automation_CompletionResultType_System_String_
  # string - the text used as the auto completion result
  # string - the text to be displayed in a list
  # CompletionResultType https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.completionresulttype?view=powershellsdk-1.1.0
  # string the text for the tooltip with details
  $result | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}.GetNewClosure()

Register-ArgumentCompleter -Native -CommandName $Command -ScriptBlock $block
