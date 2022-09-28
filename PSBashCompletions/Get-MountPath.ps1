function Get-MountPath {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseOutputTypeCorrectly", "", Justification = "False positive - https://github.com/PowerShell/PSScriptAnalyzer/issues/676")]
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $True, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [Object[]]
    $MountData
  )
  # Determine drive letter mount point based on output of 'mount' command. This
  # assumes you have a drive C and looks for either /mnt/c or just /c to find
  # where it is mounted in bash. The resulting string should be either / or
  # /mnt/
  $found = $MountData | Where-Object { $_ -match "C:" -and $_ -match "(/mnt)?/c" }
  If ($found) {
    # We found /mnt/c or /c
    $Matches[0] -replace "/c", "/"
  }
  Else {
    "/"
  }
}
