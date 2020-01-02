using namespace System
using namespace System.Collections.Specialized
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# [ステップ記録ツール(psr.exe)をコマンドラインから使いやすくしてみる(PowerShell・Register-ArgumentCompleter) - Qiita](https://qiita.com/nukie_53/items/58a5d0e4f33fb58a8bab "ステップ記録ツール(psr.exe)をコマンドラインから使いやすくしてみる(PowerShell・Register-ArgumentCompleter) - Qiita")

# Register-ArgumentCompleter に指定するスクリプトブロックを定義。
# 入力中のコマンド構文木を元に、入力候補をパイプライン出力する。
[scriptblock]$psrCompleter = {
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
    # カーソルまでの CommandElementAst(includes cursor position ast)。
    # ○○.exe があるため最低でも1要素はある。
    [CommandElementAst[]]$astsOfBeforeCursor = @($wordToComplete.CommandElements |
        Where-Object -FilterScript {
            $_.Extent.StartOffset -le $cursorPosition
        }
    )
    
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
    [hashtable]$tooltipInfo = Import-LocalizedData -BaseDirectory "$PSScriptRoot\rsc" -ErrorAction Stop
    
    if ($astsOfBeforeCursor.Extent.Text -icontains '/stop') {
        # /stop スイッチが指定されているとき、他のスイッチは全て無効のため、補完を停止。
        return
    }
    
    # 最後から1個目、2個目の情報を取得。
    # 指定しているスイッチと、その値を想定。
    [string]$last1Token = $astsOfBeforeCursor[-1].Extent.Text
    [string]$last2Token = if ($astsOfBeforeCursor.Length -ge 2) {
        $astsOfBeforeCursor[-2].Extent.Text
    } else {
        [string]::Empty
    }
    # 指定したパラメータが入力中かどうか。
    [scriptblock]$swtichIsInputting = {
        param ([string[]]$Switches)
        return (
            # カーソル前の最後の要素がスイッチかつ、カーソルがスイッチの後ろ(これから入力しようとしている場合)。
            [string]::IsNullOrEmpty($commandName) -and 
            ($last1Token -iin $Switches)
        ) -or (
            # 入力中の値を変更しようとしている場合。
            -not [string]::IsNullOrEmpty($commandName) -and 
            ($last2Token -iin $Switches)
        )
    }
    
    [string[]]$disableCompletionParameters = @(
        '/maxsc', '/maxlogsize', '/output', '/stopevent'
    )
    
    if (& $swtichIsInputting $disableCompletionParameters) {
        # カーソルの直前が任意入力のスイッチだったら、補完を停止。
        return
    }

    [string[]]$onOffParameters = @(
        '/sc', '/gui', '/arcetl', '/arcxml', '/sketch', '/slides'
    )
    if (& $swtichIsInputting $onOffParameters) {
        # カーソルの直前が 0, 1 を指定するスイッチだったら、0, 1 を表示。
        [CompletionResult]::new('0', '0 : Off', [CompletionResultType]::ParameterValue, $tooltipInfo['0'])
        [CompletionResult]::new('1', '1 : On' , [CompletionResultType]::ParameterValue, $tooltipInfo['1'])
        return
    }
    if (& $swtichIsInputting '/recordpid') {
        # カーソルの直前が /recordpid だったら、ウィンドウを持っているプロセスの ID をリストアップ。
        Get-Process |
            Where-Object -Property MainWindowHandle -NE -Value ([IntPtr]::Zero) |
            ForEach-Object -Process {
                [string]$procInfo = '{0} : {1} - {2}' -f $_.Id, $_.Name, $_.MainWindowTitle
                [CompletionResult]::new($_.Id, $procInfo, [CompletionResultType]::ParameterValue, $procInfo)
            }
        return
    }
    
    
    
    
    # 今の位置のスイッチ or 入力中の文字列にマッチするスイッチを取得。
    [string[]]$assginedParams = $wordToComplete.CommandElements.Extent.Text
    [string[]]$showSwitchs = @(
        # 補完開始位置にすでにスイッチがあればそれを優先。
        if ($tooltipInfo.Contains($commandName)) {
            $commandName
        }
        [string[]]$tmpFilterdSwitch = $allSwitchs
        [string[]]$exclusiveSwitch = @('/start', '/stop')
        # any contains.
        if ($exclusiveSwitch.Where({$assginedParams -icontains $_}).Count -ne 0) {
            $tmpFilterdSwitch = $allSwitchs.Where({$_ -inotin $exclusiveSwitch})
        }
        $tmpFilterdSwitch.Where({
            # まだ指定されていないスイッチかつ、入力中の文字列に一致するものを探す。
            ($assginedParams -inotcontains $_) -and
            $_ -imatch [regex]::Unescape($commandName)    
        })
    )
    if ($showSwitchs.Length -eq 0) {
        # 入力中の文字列が無かったり、マッチするスイッチが無かった場合は、指定していないスイッチ全部。
        $showSwitchs = $showSwitchs = $tmpFilterdSwitch.Where({$assginedParams -inotcontains $_}).ForEach({$_.ToString()})
    }
    $showSwitchs | 
        Select-Object -Unique | 
        ForEach-Object -Process {
            [CompletionResult]::new($_, $_, [CompletionResultType]::ParameterName, $tooltipInfo[$_])
        }
    return
}

Register-ArgumentCompleter -CommandName psr.exe -Native -ScriptBlock $psrCompleter