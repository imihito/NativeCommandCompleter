using namespace System
using namespace System.Collections.Specialized
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# [ステップ記録ツール(psr.exe)をコマンドラインから使いやすくしてみる(PowerShell・Register-ArgumentCompleter) - Qiita](https://qiita.com/nukie_53/items/58a5d0e4f33fb58a8bab "ステップ記録ツール(psr.exe)をコマンドラインから使いやすくしてみる(PowerShell・Register-ArgumentCompleter) - Qiita")

[scriptblock]$psrCompleter = {
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
    
    # ツールチップの情報を取得
    # see also:https://social.technet.microsoft.com/Forums/office/en-US/b78253b1-6e38-4563-9efa-4973414e9a75/problems-step-recorder-psrexe-command-line-options?forum=w7itprogeneral
    [hashtable]$tooltipInfo = 
        Import-LocalizedData -BaseDirectory "$PSScriptRoot\rsc" -ErrorAction Stop
    
    if ($beforeCursorTxt -imatch ' /(?:maxsc|maxlogsize|output|stopevent)(?: *\S+)?$') {
        # カーソルの直前が任意入力のスイッチだったら、補完を停止。
        # $wordToComplete が末尾の空白を消してしまうため判定が難しくやや不安定。
        return
    }

    if (($beforeCursorTxt -imatch ' (/(?:sc|gui|arcetl|arcxml|sketch|slides)) *$') -and [string]::IsNullOrEmpty($paramName)) {
        # カーソルの直前が 0, 1 を指定するスイッチだったら、0, 1 を表示。
        [CompletionResult]::new('0', '0 : Off', [CompletionResultType]::ParameterValue, $tooltipInfo['0'])
        [CompletionResult]::new('1', '1 : On' , [CompletionResultType]::ParameterValue, $tooltipInfo['1'])
        return
    }

    if (($beforeCursorTxt -imatch ' /recordpid *$') -and [string]::IsNullOrEmpty($paramName)) {
        # カーソルの直前が /recordpid だったら、ウィンドウを持っているプロセスの ID をリストアップ。
        Get-Process |
            Where-Object -Property MainWindowHandle -NE -Value ([IntPtr]::Zero) |
            ForEach-Object -Process {
                [string]$procInfo = '{0} : {1} - {2}' -f $_.Id, $_.Name, $_.MainWindowTitle
                [CompletionResult]::new($_.Id, $procInfo, [CompletionResultType]::ParameterValue, $procInfo)
            }
        return
    }
    
    # psr.exe 以降のテキスト(≒スイッチの部分)を取得。
    [string]$afterPsrTxt = $wordToComplete.Substring(
        $wordToComplete.IndexOf('psr.exe', [StringComparison]::OrdinalIgnoreCase)
    )
    
    if ($afterPsrTxt -imatch ' /stop *$') {
        # /stop スイッチが指定されているとき、他のスイッチは全て無効のため、補完を停止。
        return
    }
    
    # 今の位置のスイッチ or 入力中の文字列にマッチするスイッチを取得。
    [string[]]$showSwitchs = @(
        # 補完開始位置にすでにスイッチがあればそれを優先。
        if ($tooltipInfo.Contains($paramName)) {
            $paramName
        }
        $allSwitchs.Where({
            # まだ指定されていないスイッチかつ、入力中の文字列に一致するものを探す。
            $afterPsrTxt -inotmatch [regex]::Unescape($_) -and
            $_ -imatch [regex]::Unescape($paramName)    
        })
    )
    if ($showSwitchs.Length -eq 0) {
        # 入力中の文字列が無かったり、マッチするスイッチが無かった場合は、指定していないスイッチ全部。
        $showSwitchs = $allSwitchs.Where({$afterPsrTxt -inotmatch [regex]::Unescape($_)}).ForEach({$_.ToString()})
    }
    $showSwitchs | 
        Select-Object -Unique | 
        ForEach-Object -Process {
            [CompletionResult]::new($_, $_, [CompletionResultType]::ParameterName, $tooltipInfo[$_])
        }
    return
}

Register-ArgumentCompleter -CommandName psr.exe -Native -ScriptBlock $psrCompleter