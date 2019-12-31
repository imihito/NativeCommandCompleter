using namespace System.IO
using namespace System.Management.Automation

[string]$targetName = 
    [Path]::GetFileName($MyInvocation.MyCommand.Name) -replace '\.Tests', ''

    . (
    [Path]::Combine(
        ($PSScriptRoot -replace 'Tests', 'ps1'),
        $targetName
    )
)
[scriptblock]$completer =
    (Get-Variable -Name ([Path]::GetFileNameWithoutExtension($targetName) + 'Completer')).Value

[string]$cmdLn = $null
[string]$cursorPos = $null
[CompletionResult[]]$result = $null
[array]$expect = $null
Describe "psr test" {
    Context "ParamValue" {
        It "01" {
            # Arrange
            $cmdLn = 'psr.exe /sc'
            $cursorPos = $cmdLn

            # Act
            $result = & $completer '' $cmdLn $cursorPos.Length

            # Assert
            $expect = 0, 1

            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
            
        }
    }
}

