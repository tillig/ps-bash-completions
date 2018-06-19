Param(
  [string]
  $NugetAPIKey,

  [switch]
  $Publish = $False
)


Import-Module PSScriptAnalyzer -Force

$results = Invoke-ScriptAnalyzer -Path .\PSBashCompletions\PSBashCompletions.psm1
if($results.Length -gt 0) {
  Write-Error ($results | format-table | Out-String)
  Exit 1
}

Write-Output "Script analysis passed."

Test-ModuleManifest .\PSBashCompletions\PSBashCompletions.psd1 | Out-Null
if(-not $?) {
  Exit 1
}

Write-Output "Module manifest analysis passed."

if(-not [System.String]::IsNullOrWhiteSpace($NugetAPIKey)) {
  Publish-Module -Path ".\PSBashCompletions" -NugetAPIKey $NugetAPIKey -Whatif:(-not $Publish) -Verbose
}