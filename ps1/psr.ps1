using namespace System
using namespace System.Collections.Specialized
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

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

    # see also:https://social.technet.microsoft.com/Forums/office/en-US/b78253b1-6e38-4563-9efa-4973414e9a75/problems-step-recorder-psrexe-command-line-options?forum=w7itprogeneral
    [OrderedDictionary]$paramDic = [Ordered]@{
        '/start'      = '/start:「ステップ記録ツール」を起動し、記録を開始します。/output スイッチも指定する必要があります。'
        '/stop'       = '/stop:「ステップ記録ツール」を停止します。実行中の「ステップ記録ツール」のインスタンスがない場合は何も起きません。/stop スイッチを指定したとき、他のスイッチは指定できません。'
        '/sc'         = '/sc (0|1):1(On) のとき、各ステップ毎にスクリーンショットを撮影します。0(Off) または 1(On) を指定します。既定値は 1(On) です。'
        '/maxsc'      = '/maxsc <value>:記録されるスクリーンショットの最大数を指定します。'
        '/maxlogsize' = '/maxlogsize <value>:圧縮前のログファイルの容量を MB 単位で指定します。'
        '/gui'        = '/gui (0|1):1(On) のとき、「ステップ記録ツール」のウィンドウを表示します。0(Off) または 1(On) を指定します。既定値は 1(On) です。0(Off) を指定する場合、/start スイッチも指定する必要があります。'
        '/arcetl'     = '/arcetl (0|1):1(On) のとき、出力ファイルに etw ファイルを含めます。0(Off) または 1(On) を指定します。既定値は 0(Off) です。'
        '/arcxml'     = '/arcxml (0|1):1(On) のとき、出力ファイルに xml ファイルを含めます。0(Off) または 1(On) を指定します。既定値は 0(Off) です。'
        '/recordpid'  = '/recordpid <pid>:指定されたプロセス ID に関連した操作のみが記録されます。'
        '/sketch'     = '/sketch (0|1):1(On) のとき、スクリーンショットの代わりにスケッチを保存します。0(Off) または 1(On) を指定します。既定値は 0(Off) です。/sc スイッチに 0 が指定されている必要があります。'
        '/slides'     = '/slides (0|1):1(On) のとき、出力される mht ファイルにスライドショーを設定します。0(Off) または 1(On) を指定します。既定値は 1(On) です。'
        '/output'     = '/output <filepath>:出力先のファイルパスを指定します。拡張子は .zip である必要があります。'
        '/stopevent'  = '/stopevent <eventname>:ログファイルが出力された後イベントを発生させます。'
    }
    
    if ($beforeCursorTxt -imatch ' /(?:maxsc|maxlogsize|output|stopevent)(?: *\S+)?$') {
        # カーソルの直前が任意入力のスイッチだったら、補完を停止。
        # $wordToComplete が末尾の空白を消してしまうため判定が難しくｐｓｒｐｓｒやや不安定。
        return
    }

    if (($beforeCursorTxt -imatch ' (/(?:sc|gui|arcetl|arcxml|sketch|slides)) *$') -and [string]::IsNullOrEmpty($paramName)) {
        # カーソルの直前が 0, 1 を指定するスイッチだったら、0, 1 を表示。
        [CompletionResult]::new('0', '0 : Off', [CompletionResultType]::ParameterValue, '指定したスイッチを無効にします。')
        [CompletionResult]::new('1', '1 : On' , [CompletionResultType]::ParameterValue, '指定したスイッチを有効にします。')
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
        if ($paramDic.Contains($paramName)) {
            $paramName
        }
        $paramDic.Keys.Where({
            # まだ指定されていないスイッチかつ、入力中の文字列に一致するものを探す。
            $afterPsrTxt -inotmatch [regex]::Unescape($_) -and
            $_ -imatch [regex]::Unescape($paramName)    
        })
    )
    if ($showSwitchs.Length -eq 0) {
        # 入力中の文字列が無かったり、マッチするスイッチが無かった場合は、指定していないスイッチ全部。
        $showSwitchs = $paramDic.Keys.Where({$afterPsrTxt -inotmatch [regex]::Unescape($_)}).ForEach({$_.ToString()})
    }
    $showSwitchs | 
        Select-Object -Unique | 
        ForEach-Object -Process {
            [CompletionResult]::new($_, $_, [CompletionResultType]::ParameterName, $paramDic[$_])
        }
    return
}

Register-ArgumentCompleter -CommandName psr.exe -Native -ScriptBlock $psrCompleter