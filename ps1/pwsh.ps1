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
    # カーソルまでの CommandElementAst(includes cursor position ast)。astsOfBeforeCursor
    [CommandElementAst[]]$astsOfBeforeCursor = @($wordToComplete.CommandElements |
        Where-Object -FilterScript {
            $_.Extent.StartOffset -le $cursorPosition
        }
    )

    # [CommandElementAst[]] から指定した値の物を探す(IgnoreCase)。
    [scriptblock]$findSwitchIndex = {
        [OutputType([int])]param ([CommandElementAst[]]$CmdAst, [string]$FindValue)
        [int]$i = 0
        foreach ($i in 0..($CmdAst.Length - 1)) {
            if ($CmdAst[$i].Extent.Text -ieq $FindValue) {
                return $i
            }
        }
        return -1
    }
    
    [scriptblock]$filterListOrAllIfNotMatch = {
        [OutputType([string])]param ([string[]]$InputObject, [string]$FilterValue)
        [string]$ptn = [regex]::Unescape($FilterValue)
        [string[]]$result = $InputObject.Where({$_ -imatch $ptn})
        if ($result.Length -ne 0) {
            return $result
        } else {
            return $InputObject
        }
    }

    function New-CompletionResult {
        [OutputType([System.Management.Automation.CompletionResult])]param (
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [string]$CompletionText,
            [CompletionResultType]$ResultType = [CompletionResultType]::ParameterValue,
            [Parameter(ValueFromPipeline = $true)]
            [string]$ListItemText = [string]::Empty,
            [Parameter(ValueFromPipeline = $true)]
            [string]$ToolTip      = [string]::Empty
        )
        process {
            [CompletionResult]::new($CompletionText, $ListItemText, $ResultType, $ToolTip)
        }
    }

    [string[]]$allSwitchs = @(
        '-File'
        '-Command'
        '-ExecutionPolicy'
        '-NoProfile'
        '-NoExit'
        '-WindowStyle'
    )
    [hashtable]$tooltipInfo = Import-LocalizedData -BaseDirectory "$PSScriptRoot\rsc"
    
    #region -Command
    if ($astsOfBeforeCursor.Extent.Text -icontains '-Command') {
        return # カーソルが -Command より後ろにあれば、自前の補完は無効にする。
    }
    #endregion

    #region -File
    switch (& $findSwitchIndex $astsOfBeforeCursor '-File') {
        -1 {break}
        ($astsOfBeforeCursor.Length - 1) {# -File の直後の場合。
            Get-ChildItem -LiteralPath $PWD.ProviderPath -Filter '*.ps1' -Include '*.ps1' -File -Name -Recurse -Depth 3 |
                Select-Object -First 20 | # 多すぎると PSReadLine の候補表示がうまくいかないため。
                New-CompletionResult -CompletionText {
                    "'.\" + [CodeGeneration]::EscapeSingleQuotedStringContent($_) + "'"
                } -ListItemText {
                    [IO.Path]::GetFileName($_)
                } -ToolTip {
                    [IO.Path]::Combine($PWD.ProviderPath, $_) + $(
                        try {
                            "`n" + (
                                (Get-Command -Name ".\$_").ParameterSets.ForEach({$_.ToString()}) -join "`n`n"
                            )
                        } catch {
                            ''
                        }
                    )
                } -ResultType Command
            return
        }
        Default { # -File 以降かつ、-File に何か指定している場合。
            [CommandElementAst]$maybeFilePathAst = $astsOfBeforeCursor[$_ + 1]
            (Get-Command -Name $maybeFilePathAst.SafeGetValue()).Parameters.GetEnumerator() |
            ForEach-Object -Process {
                [ParameterMetadata]$meta = $_.Value
                [string]$toolTip = '[{0}] {1}' -f $meta.ParameterType.Name, $_.Key
                New-CompletionResult -CompletionText "-$($_.Key)" -ListItemText $_.Key -ToolTip $toolTip -ResultType ParameterName
            }
            return
        }
    }
    #endregion
    
    #region -ExecutionPolicy
    switch (& $findSwitchIndex $astsOfBeforeCursor '-ExecutionPolicy') {
        -1 {break}
        ($astsOfBeforeCursor.Length - 1) { # -ExecutionPolicy の直後の場合。
            [Enum]::GetNames([Microsoft.PowerShell.ExecutionPolicy]) |
                New-CompletionResult -ResultType ParameterValue
            return
        }
        ($astsOfBeforeCursor.Length - 2) {
            if ([string]::IsNullOrEmpty($commandName)) {break}
            $filterListOrAllIfNotMatch.Invoke(
                [Enum]::GetNames([Microsoft.PowerShell.ExecutionPolicy]),
                $commandName
            ) | New-CompletionResult -ResultType ParameterValue
            return
        }
    }
    #endregion
    #region -WindowStyle
    switch (& $findSwitchIndex $astsOfBeforeCursor '-WindowStyle') {
        -1 {break}
        ($astsOfBeforeCursor.Length - 1) { # -WindowStyle の直後の場合。
            [Enum]::GetNames([Diagnostics.ProcessWindowStyle]) |
                New-CompletionResult -ResultType ParameterValue
            return
        }
        ($astsOfBeforeCursor.Length - 2) {
            if ([string]::IsNullOrEmpty($commandName)) {break}
            $filterListOrAllIfNotMatch.Invoke(
                [Enum]::GetNames([Diagnostics.ProcessWindowStyle]),
                $commandName
            ) | New-CompletionResult -ResultType ParameterValue
            return
        }
    }
    #endregion
    #region Parameter
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
        [string[]]$assginedParams = $wordToComplete.CommandElements.Extent.Text
        $showSwitchs = $allSwitchs.Where({$assginedParams -inotcontains $_}).ForEach({$_.ToString()})
    }
    $showSwitchs | 
        Select-Object -Unique | 
        New-CompletionResult -ResultType ParameterName -ToolTip {$tooltipInfo[$_]}
    return
    #endregion
}

Register-ArgumentCompleter -CommandName powershell.exe, pwsh.exe -Native -ScriptBlock $pwshCompleter