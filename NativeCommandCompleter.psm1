param (
    [ValidateNotNullOrEmpty()]
    [string[]]$CommandName = @(
        'psr'
    )
)
Set-StrictMode -Version Latest
<#
,
    [string[]]$Include = @()
    ,
    [string[]]$Exclude = @()
#>
$CommandName | 
    ForEach-Object -Process {
        # Register-ArgumentCompleter is global, so no need dot source.
        & "$PSScriptRoot\ps1\$_.ps1"
    }

Export-ModuleMember -Function @()