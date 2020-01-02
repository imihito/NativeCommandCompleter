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
        [string]$paramName
        ,
        # 入力中のコマンド全体(末尾のスペースは無視)。
        [Parameter(Position = 1)]
        [string]$wordToComplete
        ,
        # 補完を開始したカーソルの位置。
        [Parameter(Position = 2)]
        [int]$cursorPosition
    )
    # カーソル直前までのコマンド文字列。
    [string]$beforeCursorTxt = $wordToComplete.Substring(0, [Math]::Min($cursorPosition, $wordToComplete.Length))
    
    [string[]]$allSwitchs = @(
        '-File'
        '-Command'
        '-ExecutionPolicy'
    )
    [hashtable]$tooltipInfo = 
        Import-LocalizedData -BaseDirectory "$PSScriptRoot\rsc"
    
    if ($beforeCursorTxt -imatch ' -Command *') {
        return
    }

    if ($beforeCursorTxt -imatch ' -File *$') {
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
    if ($beforeCursorTxt -imatch '\.exe(?: .*)? -File +["'']?(.+\.ps1)["'']' -and [string]::IsNullOrWhiteSpace($paramName)) {
        (Get-Command -Name $Matches[1]).Parameters.GetEnumerator() |
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

    # psr.exe 以降のテキスト(≒スイッチの部分)を取得。
    [string]$afterCommandTxt = $wordToComplete.Substring(
        $wordToComplete.IndexOf('.exe', [StringComparison]::OrdinalIgnoreCase) + '.exe'.Length
    )
    # 今の位置のスイッチ or 入力中の文字列にマッチするスイッチを取得。
    [string[]]$showSwitchs = @(
        # 補完開始位置にすでにスイッチがあればそれを優先。
        if ($tooltipInfo.Contains($paramName)) {
            $paramName
        }
        $allSwitchs.Where({
            # まだ指定されていないスイッチかつ、入力中の文字列に一致するものを探す。
            $afterCommandTxt -inotmatch [regex]::Unescape($_) -and
            $_ -imatch [regex]::Unescape($paramName)    
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