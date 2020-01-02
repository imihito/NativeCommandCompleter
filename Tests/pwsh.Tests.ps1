using namespace System.IO
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

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

[string]$commandName = [string]::Empty
[CommandAst]$wordToComplete = $null
[int]$cursorPosition = $null
[CompletionResult[]]$result = $null
[array]$expect = $null
Describe 'powershell.exe' {
    Context 'Parameter Name' {
        It 'All' {
            # Arrange
            $commandName    = ''
            $wordToComplete = {powershell.exe}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
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
            $commandName    = ''
            $wordToComplete = {powershell.exe -Command}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
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
            $commandName    = ''
            $wordToComplete = {powershell.exe -NoProfile -Command}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @()
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }

        It 'Command3' {
            # Arrange
            $commandName    = ''
            $wordToComplete = {powershell.exe -Command Get-ChildItem}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @()
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }
    }

    Context 'ExecutionPolicy' {
        It 'Is last parameter' {
            # Arrange
            $commandName    = ''
            $wordToComplete = {powershell.exe -ExecutionPolicy}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset + 1
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @([System.Enum]::GetNames([Microsoft.PowerShell.ExecutionPolicy]))
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }
        It 'User inputting.' {
            # Arrange
            $commandName    = 'remote'
            $wordToComplete = {powershell.exe -ExecutionPolicy remote}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @(
                [System.Enum]::GetNames([Microsoft.PowerShell.ExecutionPolicy]).Where({
                    $_ -imatch $commandName
                })
            )
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }
        It 'User input is invalid.' {
            # Arrange
            $commandName    = 'aaa'
            $wordToComplete = {powershell.exe -ExecutionPolicy remote}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @(
                [System.Enum]::GetNames([Microsoft.PowerShell.ExecutionPolicy])
            )
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }
    }
}