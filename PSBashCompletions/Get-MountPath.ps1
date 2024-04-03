function Get-MountPath {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Object[]]
        $MountData
    )
    # Determine if drive letter mount point is /mnt/ prefixed based on
    # output of 'mount' command. This searches to see if your mounts use
    # the /mnt/[a-z] drive letter mounting format (Git Bash or similar)
    # or else returns / for use with the /[a-z] (WSL2) or / (Mac/Linux) mounting
    # format for use in path resolution to bash.
    #
    # The resulting string will be either /mnt/ or /
    $found = $MountData | Where-Object { $_ -match 'on /mnt/[a-z] ' }
    If ($found) {
        '/mnt/'
    }
    Else {
        '/'
    }
}
