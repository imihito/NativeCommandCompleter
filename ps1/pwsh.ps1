using namespace System
using namespace System.Collections.Specialized
using namespace System.Management.Automation
using namespace System.Management.Automation.Language


[scriptblock]$pwshCompleter = {
    [CmdletBinding(HelpUri = 'https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter')]
    [OutputType([System.Management.Automation.CompletionResult])]
    param (
        # 入力中のスイッチ。
        [Parameter(Position = 0)]
        [string]$commandName
        ,
        # 入力中のコマンド構文木。
        [Parameter(Position = 1)]
        [CommandAst]$wordToComplete
        ,
        # 補完を開始したカーソルの位置。
        [Parameter(Position = 2)]
        [int]$cursorPosition
    )
    [CommandElementAst[]]$beforeCursorAsts = @($wordToComplete.CommandElements |
        Where-Object -FilterScript {
            $_.Extent.StartOffset -le $cursorPosition
        }
    )
    [string]$lastToken   = [string]($beforeCursorAsts.Extent.Text | Select-Object -Last 1)
    [string]$cursorToken = $beforeCursorAsts.Extent |
        Where-Object -FilterScript {
            $_.EndOffset   -ge $cursorPosition
        } | ForEach-Object -Process {$_.Text}
    [scriptblock]$findSwitchIndex = {
        [OutputType([int])]
        param (
            [CommandElementAst[]]$CmdAst, 
            [string]$FindValue
        )
        [int]$i = 0
        foreach ($i in 0..($CmdAst.Length - 1)) {
            if ($CmdAst[$i].Extent.Text -ieq $FindValue) {
                return $i
            }
        }
        return -1
    }
    
    # カーソル直前までのコマンド文字列。
    #[string]$beforeCursorTxt = $wordToComplete.Substring(0, [Math]::Min($cursorPosition, $wordToComplete.Length))
    
    [string[]]$allSwitchs = @(
        '-File'
        '-Command'
        '-ExecutionPolicy'
    )
    [hashtable]$tooltipInfo = 
        Import-LocalizedData -BaseDirectory "$PSScriptRoot\rsc"
    
    if ($beforeCursorAsts.Extent.Text -icontains '-Command') {
        # カーソルが -Command より後ろにあれば、自前の補完は無効にする。
        return
    }
    
    switch (& $findSwitchIndex $beforeCursorAsts '-File') {
        -1 {break}
        $beforeCursorAsts.Length {
            # 最後だったら
            Get-ChildItem -LiteralPath $PWD.ProviderPath -Filter '*.ps1' -Include '*.ps1' -File -Name -Recurse -Depth 3 |
                Select-Object -First 20 |
                ForEach-Object -Process {
                    [CompletionResult]::new(
                        "'.\" + [CodeGeneration]::EscapeSingleQuotedStringContent($_) + "'",
                        [IO.Path]::GetFileName($_),
                        [CompletionResultType]::Command,
                        [IO.Path]::Combine($PWD.ProviderPath, $_)
                    )
                    # TODO
                    # .ParameterSets[0].ToString()
                }
            return
        }
        Default {
            [CommandElementAst]$maybeFilePathAst = $beforeCursorAsts[$_ + 1]
            (Get-Command -Name $maybeFilePathAst.SafeGetValue()).Parameters.GetEnumerator() |
            ForEach-Object -Process {
                [ParameterMetadata]$meta = $_.Value
                [string]$toolTip = '[{0}] {1}' -f $meta.ParameterType.Name, $_.Key
                [CompletionResult]::new(
                    '-' + $_.Key,
                    $_.Key,
                    [CompletionResultType]::ParameterValue,
                    $toolTip
                )
            }
            return
        }
    }
    
    if ($lastToken -ieq '-ExecutionPolicy' -and [string]::IsNullOrEmpty($cursorToken)) {
        # ExecutionPolicy の指定
        [Enum]::GetNames([Microsoft.PowerShell.ExecutionPolicy]).ForEach({
            [CompletionResult]::new(
                $_,
                $_,
                [CompletionResultType]::ParameterValue,
                $_
            )
        })
        return
    }

    # psr.exe 以降のテキスト(≒スイッチの部分)を取得。
    [string]$afterCommandTxt = $wordToComplete.Extent.Text.Substring(
        $wordToComplete.Extent.Text.IndexOf('.exe', [StringComparison]::OrdinalIgnoreCase) + '.exe'.Length
    )
    # 今の位置のスイッチ or 入力中の文字列にマッチするスイッチを取得。
    [string[]]$showSwitchs = @(
        # 補完開始位置にすでにスイッチがあればそれを優先。
        if ($tooltipInfo.Contains($commandName)) {
            $commandName
        }
        $allSwitchs.Where({
            # まだ指定されていないスイッチかつ、入力中の文字列に一致するものを探す。
            (& $findSwitchIndex $wordToComplete.CommandElements $_) -eq -1 -and
            $_ -imatch [regex]::Unescape($commandName)    
        })
    )
    if ($showSwitchs.Length -eq 0) {
        # 入力中の文字列が無かったり、マッチするスイッチが無かった場合は、指定していないスイッチ全部。
        $showSwitchs = $allSwitchs.Where({$afterCommandTxt -inotmatch [regex]::Unescape($_)}).ForEach({$_.ToString()})
    }
    $showSwitchs | 
        Select-Object -Unique | 
        ForEach-Object -Process {
            [CompletionResult]::new($_, $_, [CompletionResultType]::ParameterName, $tooltipInfo[$_])
        }
    return
}

Register-ArgumentCompleter -CommandName powershell.exe, pwsh.exe -Native -ScriptBlock $pwshCompleter