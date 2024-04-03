Param(
    [string]
    $NugetAPIKey,

    [switch]
    $Publish = $False
)

Import-Module Pester
Import-Module PSScriptAnalyzer -Force

$results = Invoke-ScriptAnalyzer -Path .\PSBashCompletions -Recurse -ReportSummary -Settings .\PSScriptAnalyzerSettings.psd1
if ($results.Length -gt 0) {
    Write-Error ($results | Format-Table | Out-String)
    Exit 1
}

Write-Output 'Script analysis passed.'

Test-ModuleManifest .\PSBashCompletions\PSBashCompletions.psd1 | Out-Null
if (-not $?) {
    Exit 1
}

Write-Output 'Module manifest analysis passed.'

$configuration = [PesterConfiguration]::Default
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$result = Invoke-Pester -Configuration $configuration
if ($result.failedCount -ne 0) {
    Write-Error 'Unit tests failed. See report for details.'
    Exit 1
}

if (-not [System.String]::IsNullOrWhiteSpace($NugetAPIKey)) {
    Publish-Module -Path '.\PSBashCompletions' -NuGetApiKey $NugetAPIKey -WhatIf:(-not $Publish) -Verbose
}
