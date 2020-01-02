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

[string]$commandName = $null
[CommandAst]$wordToComplete = $null
[int]$cursorPosition = $null
[CompletionResult[]]$result = $null
[array]$expect = $null
Describe 'psr.exe' {
    Context 'Parameter Name' {
        It 'All' {
            # Arrange
            $commandName    = ''
            $wordToComplete = {psr.exe}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @(
                '/start'
                '/stop'
                '/sc'
                '/maxsc'
                '/maxlogsize'
                '/gui'
                '/arcetl'
                '/arcxml'
                '/recordpid'
                '/sketch'
                '/slides'
                '/output'
                '/stopevent'
            )
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }

        It 'User input is invalid' {
            # Arrange
            $commandName    = 'invalidparam'
            $wordToComplete = {psr.exe invalidparam}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @(
                '/start'
                '/stop'
                '/sc'
                '/maxsc'
                '/maxlogsize'
                '/gui'
                '/arcetl'
                '/arcxml'
                '/recordpid'
                '/sketch'
                '/slides'
                '/output'
                '/stopevent'
            )
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }
        
        It 'Filter used1' {
            # Arrange
            $commandName    = ''
            $wordToComplete = {psr.exe /start /sc 1}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @(
                '/maxsc'
                '/maxlogsize'
                '/gui'
                '/arcetl'
                '/arcxml'
                '/recordpid'
                '/sketch'
                '/slides'
                '/output'
                '/stopevent'
            )
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }

        It 'Filter by inputting command' {
            # Arrange
            $commandName    = 'st'
            $wordToComplete = {psr.exe st}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @(
                '/start'
                '/stop'
                '/stopevent'
            )
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }

        It 'Filter used2' {
            # Arrange
            $commandName    = ''
            $wordToComplete = {psr.exe /start /sc 1}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset - ' /sc 1'.Length
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @(
                '/maxsc'
                '/maxlogsize'
                '/gui'
                '/arcetl'
                '/arcxml'
                '/recordpid'
                '/sketch'
                '/slides'
                '/output'
                '/stopevent'
            )
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }

        It 'Current parameter' {
            # Arrange
            $commandName    = '/start'
            $wordToComplete = {psr.exe /start /sc 1}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset - 'rt /sc 1'.Length
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @(
                '/start'
            )
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }

        It 'Contains /stop' {
            # Arrange
            $commandName    = '/stop'
            $wordToComplete = {psr.exe /stop}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset - 2
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

    Context 'Disable Completion Parameter' {
        It 'Is Last parameter' {
            # Arrange
            $commandName    = ''
            $wordToComplete = {psr.exe /output}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset + 1
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @()
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_] | Should Be $expect[$_]
                }
        }
        It 'UserInputing' {
            # Arrange
            $commandName    = '.\'
            $wordToComplete = {psr.exe /output .\}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = @()
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_] | Should Be $expect[$_]
                }
        }
    }
    Context 'On Off Parameter' {
        It 'Is Last parameter' {
            # Arrange
            $commandName    = ''
            $wordToComplete = {psr.exe /sc}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = 0, 1

            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }

        It 'UserInputing1' {
            # Arrange
            $commandName    = '0'
            $wordToComplete = {psr.exe /sc 0}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset - 1
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $expect = 0, 1
            $result.Length | Should Be $expect.Length
            0..($result.Length - 1) |
                ForEach-Object -Process {
                    $result[$_].CompletionText | Should Be $expect[$_]
                }
        }
    }

    Context '/recordpid' {
        It 'PID' {
            # Arrange
            $commandName    = ''
            $wordToComplete = {psr.exe /recordpid}.Ast.EndBlock.Statements[0].PipelineElements[0]
            $cursorPosition = $wordToComplete.Extent.EndOffset + 1
            $proc = Start-Process -FilePath notepad -PassThru
            $proc.WaitForInputIdle() > $null
            Start-Sleep -Milliseconds 50
            # Act
            $result = @(& $completer $commandName $wordToComplete $cursorPosition)
            # Assert
            $result.CompletionText -contains $proc.Id | Should Be $true 
            $proc.Kill()
        }
    }
}

