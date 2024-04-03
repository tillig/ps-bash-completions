# If the command is an alias, this expands it to be the full command
# name. If it's not an alias, it exits untouched.
function Expand-Command {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Command
    )

    $alias = Get-Alias -Name $Command -ErrorAction Ignore
    if (($null -eq $alias) -or ($null -eq $alias.ResolvedCommandName)) {
        Write-Verbose "$Command is not an alias."
        return $Command
    }

    $resolved = $alias.ResolvedCommandName
    $pathext = $Env:PATHEXT
    if ($null -eq $pathext) {
        Write-Verbose "$Command is an alias for $resolved."
        return $resolved
    }

    foreach ($ext in $pathext.Split(';')) {
        if ($resolved.EndsWith($ext, [System.StringComparison]::OrdinalIgnoreCase)) {
            $resolved = $resolved.Substring(0, $resolved.Length - $ext.Length)
            break
        }
    }

    Write-Verbose "$Command is an alias for $resolved."
    return $resolved
}
