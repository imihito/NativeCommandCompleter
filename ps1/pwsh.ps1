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

    [string[]]$allSwitchs = @()
    [hashtable]$tooltipInfo = 
        Import-LocalizedData -BaseDirectory "$PSScriptRoot\rsc"
}

Register-ArgumentCompleter -CommandName psr.exe -Native -ScriptBlock $pwshCompleter