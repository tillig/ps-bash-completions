# Bash Argument Completer
# PowerShell module for marshaling bash completions into PowerShell.

@{
    RootModule             = '.\PSBashCompletions.psm1'
    ModuleVersion          = '1.2.6'
    GUID                   = '55f0d5a8-c664-43cd-ac46-f4b3d9e97825'
    Author                 = 'Travis Illig'
    Copyright              = '(c) 2018 Travis Illig. All rights reserved.'
    Description            = 'PSBashCompletions offers the ability to process bash completions into PowerShell.'
    PowerShellVersion      = '5.0'
    DotNetFrameworkVersion = '2.0'
    FunctionsToExport      = @('Register-BashArgumentCompleter')
    CmdletsToExport        = @()
    VariablesToExport      = @()
    AliasesToExport        = @()
    PrivateData            = @{
        PSData = @{
            Tags       = @('Regiser-ArgumentCompleter', 'New-CompletionResult', 'bash')
            LicenseUri = 'https://github.com/tillig/ps-bash-completions/blob/master/LICENSE'
            ProjectUri = 'https://github.com/tillig/ps-bash-completions'
            IconUri    = ''
        }
    }
}
