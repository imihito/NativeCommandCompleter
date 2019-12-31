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
Describe 'psr.exe' {
    Context 'Parameter Name' {
        It 'All' {
            # Arrange
            $cmdLn     = 'psr.exe'
            $cursorPos = $cmdLn
            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)
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
            $cmdLn     = 'psr.exe invalidparam'
            $cursorPos = $cmdLn
            # Act
            $result = @(& $completer 'invalidparam' $cmdLn $cursorPos.Length)
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
            $cmdLn     = 'psr.exe /start /sc 1'
            $cursorPos = $cmdLn
            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)
            # Assert
            $expect = @(
                '/stop'
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
            $cmdLn     = 'psr.exe st'
            $cursorPos = 'psr.exe st'
            # Act
            $result = @(& $completer 'st' $cmdLn $cursorPos.Length)
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
            $cmdLn     = 'psr.exe /start /sc 1'
            $cursorPos = 'psr.exe /start'
            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)
            # Assert
            $expect = @(
                '/stop'
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
            $cmdLn     = 'psr.exe /start /sc 1'
            $cursorPos = 'psr.exe /sta'
            # Act
            $result = @(& $completer '/start' $cmdLn $cursorPos.Length)
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
            $cmdLn     = 'psr.exe /stop'
            $cursorPos = 'psr.exe /st'
            # Act
            $result = @(& $completer '/stop' $cmdLn $cursorPos.Length)
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
            $cmdLn     = 'psr.exe /output'
            $cursorPos = $cmdLn
            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)
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
            $cmdLn     = 'psr.exe /output .\'
            $cursorPos = $cmdLn
            # Act
            $result = @(& $completer '.\' $cmdLn $cursorPos.Length)
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
            $cmdLn     = 'psr.exe /sc'
            $cursorPos = $cmdLn
            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)
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
            $cmdLn     = 'psr.exe /sc 0'
            $cursorPos = 'psr.exe /sc'

            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)

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
            $cmdLn     = 'psr.exe /recordpid'
            $cursorPos = $cmdLn
            $proc = Start-Process -FilePath notepad -PassThru
            $proc.WaitForInputIdle() > $null
            Start-Sleep -Milliseconds 50
            # Act
            $result = @(& $completer '' $cmdLn $cursorPos.Length)
            # Assert
            $result.CompletionText -contains $proc.Id | Should Be $true 
            $proc.Kill()
        }
    }
}

