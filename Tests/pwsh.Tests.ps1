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
Describe 'powershell.exe' {
    Context 'Parameter Name' {
        It 'All' {
            # Arrange
            $cmdLn     = 'powershell.exe'
            $cursorPos = $cmdLn
            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)
            # Assert
            $expect = @(
                '-File'
                '-Command'
                '-ExecutionPolicy'
            )
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }
    }
    Context 'Disable Completion Parameter' {
        It 'Command1' {
            # Arrange
            $cmdLn     = 'powershell.exe -Command'
            $cursorPos = $cmdLn
            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)
            # Assert
            $expect = @()
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }
        It 'Command2' {
            # Arrange
            $cmdLn     = 'powershell.exe -NoProfile -Command'
            $cursorPos = $cmdLn
            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)
            # Assert
            $expect = @()
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }
    }
}