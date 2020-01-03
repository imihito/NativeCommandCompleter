<#
.SYNOPSIS
For powershell.exe / pwsh.exe ja-JP ToolTips.
.DESCRIPTION
PowerShell[.exe]
    [-PSConsoleFile <file> | -Version <version>]
    [-NoLogo]
    [-NoExit]
    [-Sta]
    [-Mta]
    [-NoProfile]
    [-NonInteractive]
    [-InputFormat {Text | XML}]
    [-OutputFormat {Text | XML}]
    [-WindowStyle <style>]
    [-EncodedCommand <Base64EncodedCommand>]
    [-ConfigurationName <string>]
    [-File - | <filePath> <args>]
    [-ExecutionPolicy <ExecutionPolicy>]
    [-Command - | { <script-block> [-args <arg-array>] }
                | { <string> [<CommandParameters>] } ]

PowerShell[.exe] -Help | -? | /?

pwsh[.exe]
   [[-File] <filePath> [args]]
   [-Command { - | <script-block> [-args <arg-array>]
                 | <string> [<CommandParameters>] } ]
   [-ConfigurationName <string>]
   [-CustomPipeName <string>]
   [-EncodedCommand <Base64EncodedCommand>]
   [-ExecutionPolicy <ExecutionPolicy>]
   [-InputFormat {Text | XML}]
   [-Interactive]
   [-NoExit]
   [-NoLogo]
   [-NonInteractive]
   [-NoProfile]
   [-OutputFormat {Text | XML}]
   [-SettingsFile <SettingsFilePath>]
   [-Version]
   [-WindowStyle <style>]
   [-WorkingDirectory <directoryPath>]

pwsh[.exe] -h | -Help | -? | /?
.LINK
https://docs.microsoft.com/ja-jp/powershell/module/Microsoft.PowerShell.Core/About/about_PowerShell_exe?view=powershell-5.1
.LINK
https://docs.microsoft.com/ja-jp/powershell/module/Microsoft.PowerShell.Core/About/about_pwsh?view=powershell-6
#>
@{
    #region # powershell.exe / pwsh.exe Common Parameters
    # 指定された場合、直後の補完では ps1 ファイルだけを表示する。何か入力されたら補完は停止する。
    # ps1ファイルが指定されたことを検知したら、パラメータを表示してもいいかも？
    '-File'              = @'
-File - | <filePath> <args>
指定されたスクリプトをローカル スコープ ("ドット ソース") で実行して、スクリプトによって作成された関数と変数を現在のセッションで使用できるようにします。スクリプト ファイルのパスとパラメーターを入力します。
File はコマンド内で最後のパラメーターである必要があります。File パラメーター名の後に入力された文字は、スクリプト ファイルのパスとスクリプトのパラメーターとして解釈されるためです。
'@
    # 指定された場合、以降の補完は停止する。
    '-Command'           = @'
-Command - | { <script-block> [-args <arg-array>] }
           | { <string> [<CommandParameters>] } 
PowerShell のコマンド プロンプトに入力された場合と同様に、指定されたコマンド (および任意のパラメーター) を実行します。NoExit が指定されていない場合は、そのまま終了します。Command の値には、"-"、文字列、またはスクリプトブロックを指定できます。
Command の値が "-" の場合、コマンド テキストは標準入力から読み込まれます。
Command の値がスクリプト ブロックの場合は、スクリプト ブロックを中かっこ({}) で囲む必要があります。スクリプト ブロックを指定できるのは、PowerShell で PowerShell.exe を実行している場合だけです。スクリプト ブロックの結果は、ライブ オブジェクトではなく逆シリアル化 XML オブジェクトとして親シェルに返されます。
Command の値が文字列の場合、Command はコマンド内で最後のパラメーターである必要があります。コマンドの後に入力された文字は、コマンド引数として解釈されるためです。
'@
    '-ExecutionPolicy'   = @'
-ExecutionPolicy {Unrestricted | RemoteSigned | AllSigned | Restricted | Restricted | Bypass | Undefined}
現在のセッションの既定の実行ポリシーを設定し、$env:PSExecutionPolicyPreference 環境変数に保存します。
このパラメーターでは、レジストリに設定されている PowerShell 実行ポリシーは変更されません。
'@
    '-NoProfile'         = @'
-NoProfile
PowerShell プロファイルを読み込みません。
'@
    '-NoExit'            = @'
-NoExit
スタートアップ コマンドを実行後、終了しません。
'@
    '-WindowStyle'       = @'
-WindowStyle {Normal | Minimized | Maximized | Hidden}
ウィンドウ スタイルを Normal、Minimized、Maximized、または Hidden に設定します。
'@
    '-EncodedCommand'    = @'
-EncodedCommand <Base64EncodedCommand>
Base-64 エンコードの文字列のコマンドを受け付けます。複雑な引用符や中かっこが必要なコマンドを PowerShell に送るには、このパラメーターを使用します。
文字列は UTF-16LE の形式でエンコードする必要があります。
'@
    '-InputFormat'       = @'
-InputFormat {Text | XML}
PowerShell に送られたデータの形式を指定します。
有効な値は、"Text"(テキスト文字列) または "XML" (シリアル化 CLIXML 形式) です。
'@
    '-OutputFormat'      = @'
-OutputFormat {Text | XML}
PowerShell からの出力の形式を決定します。
有効な値は、"Text" (テキスト文字列) または "XML" (シリアル化 CLIXML 形式) です。
'@
    '-NoLogo'            = @'
-NoLogo
スタートアップ時に著作権の見出しを非表示にします。
'@
    '-NonInteractive'    = @'
-NonInteractive
ユーザーに対話的なプロンプトを表示しません。
'@
    '-ConfigurationName' = @'
-ConfigurationName <string>
PowerShell が実行される構成エンドポイントを指定します。
ローカル コンピューターに登録された任意のエンドポイントを指定できます。
たとえば、既定の PowerShell リモート処理エンドポイントや、特定のユーザー機能を持つカスタム エンドポイントなどを指定できます。
'@
    '-Help'              = @'
-Help | -? | /?
ヘルプメッセージを表示します。
'@
    #endregion
    #region # powershell.exe only parameters
    '-Sta'               = @'
-Sta
シングルスレッド アパートメントを使用して、シェルを起動します。
既定ではシングルスレッド アパートメント (STA) です。
'@
    '-Mta'               = @'
-Mta
マルチスレッド アパートメントを使用して、シェルを起動します。
'@
    '-PSConsoleFile'     = @'
-PSConsoleFile <file> | -Version <version>
指定された PowerShell コンソール ファイルを読み込みます。コンソール ファイルの作成には、PowerShell の Export-Console を使用します。
'@
    <# 
    '-Version'=@'
-Version <version>
指定されたバージョンの Windows PowerShell を起動します。
このパラメーターでバージョン番号 ("-version 2.0" など) を入力します。
'@#>
    #endregion
    <#
''=@'
'@
# powershell / pwsh.exe different
[-Version]

# powershell.exe only
[-PSConsoleFile <file> | -Version <version>]
[-Sta]
[-Mta]
# pwsh.exe only
[-Interactive]
[-CustomPipeName <string>]
Specifies the name to use for an additional IPC server (named pipe) used for debugging and other cross-process communication. This offers a predictable mechanism for connecting to other PowerShell instances. Typically used with the CustomPipeName parameter on Enter-PSHostProcess.

This parameter was introduced in PowerShell 6.2.

[-SettingsFile <SettingsFilePath>]
[-WorkingDirectory <directoryPath>]

pwsh[.exe] -h | -Help | -? | /?
PowerShell[.exe] -Help | -? | /?

#>
}

<#

PowerShell[.exe] [-PSConsoleFile <ファイル> | -Version <バージョン>]
    [-NoLogo] [-NoExit] [-Sta] [-Mta] [-NoProfile] [-NonInteractive]
    [-InputFormat {Text | XML}] [-OutputFormat {Text | XML}]
    [-WindowStyle <スタイル>] [-EncodedCommand <Base64 エンコードのコマンド>]
    [-ConfigurationName <文字列>]
    [-File <ファイル パス> <引数>] [-ExecutionPolicy <実行ポリシー>]
    [-Command { - | <スクリプト ブロック> [-args <引数の配列>]
                  | <文字列> [<コマンド パラメーター>] } ]

PowerShell[.exe] -Help | -? | /?

-PSConsoleFile
    指定された Windows PowerShell コンソール ファイルを読み込みます。コンソー
    ル ファイルの作成には、Windows PowerShell の Export-Console を使用します。

-Version
    指定されたバージョンの Windows PowerShell を起動します。
    このパラメーターでバージョン番号 ("-version 2.0" など) を入力します。

-NoLogo
    スタートアップ時に著作権の見出しを非表示にします。

-NoExit
    スタートアップ コマンドを実行後、終了しません。

-Sta
    シングルスレッド アパートメントを使用して、シェルを起動します。
    既定ではシングルスレッド アパートメント (STA) です。

-Mta
    マルチスレッド アパートメントを使用して、シェルを起動します。

-NoProfile
    Windows PowerShell プロファイルを読み込みません。

-NonInteractive
    ユーザーに対話的なプロンプトを表示しません。

-InputFormat
    Windows PowerShell に送られたデータの形式を指定します。有効な値は、"Text"
    (テキスト文字列) または "XML" (シリアル化 CLIXML 形式) です。

-OutputFormat
    Windows PowerShell からの出力の形式を決定します。有効な値は、"Text" (テ
    キスト文字列) または "XML" (シリアル化 CLIXML 形式) です。

-WindowStyle
    ウィンドウ スタイルを Normal、Minimized、Maximized、または Hidden に設定します。

-EncodedCommand
    Base-64 エンコードの文字列のコマンドを受け付けます。複雑な引用符や中かっ
    こが必要なコマンドを Windows PowerShell に送るには、このパラメーターを使
    用します。

-ConfigurationName
    Windows PowerShell が実行される構成エンドポイントを指定します。
    ローカル コンピューターに登録された任意のエンドポイントを指定できます。
    たとえば、既定の Windows PowerShell リモート処理エンドポイントや、特定の
    ユーザー機能を持つカスタム エンドポイントなどを指定できます。
    
-File
    指定されたスクリプトをローカル スコープ ("ドット ソース") で実行して、
    スクリプトによって作成された関数と変数を現在のセッションで使用できるように
    します。スクリプト ファイルのパスとパラメーターを入力します。
    File はコマンド内で最後のパラメーターである必要があります。File パラメーター
   名の後に入力された文字は、スクリプト ファイルのパスとスクリプトのパラメー
    ターとして解釈されるためです。

-ExecutionPolicy
    現在のセッションの既定の実行ポリシーを設定し、
    $env:PSExecutionPolicyPreference 環境変数に保存します。
    このパラメーターでは、レジストリに設定されている Windows PowerShell 実行
    ポリシーは変更されません。

-Command
    PowerShell のコマンド プロンプトに入力された場合と同様に、指定されたコマ
    ンド (および任意のパラメーター) を実行します。NoExit が指定されていない場
    合は、そのまま終了します。Command の値には、"-"、文字列、またはスクリプト
    ブロックを指定できます。

    Command の値が "-" の場合、コマンド テキストは標準入力から読み込まれます。

    Command の値がスクリプト ブロックの場合は、スクリプト ブロックを中かっこ
    ({}) で囲む必要があります。スクリプト ブロックを指定できるのは、Windows 
    PowerShell で PowerShell.exe を実行している場合だけです。スクリプト ブロ
    ックの結果は、ライブ オブジェクトではなく逆シリアル化 XML オブジェクトと
    して親シェルに返されます。

    Command の値が文字列の場合、Command はコマンド内で最後のパラメーターである
    必要があります。コマンドの後に入力された文字は、コマンド引数として解釈さ
    れるためです。

    Windows PowerShell コマンドを実行する文字列を記述するには、次の形式を使用します。
	"& {<コマンド>}"
    引用符によりこれが文字列であることを示し、呼び出し演算子 (&) によりコマ
    ンドが実行されます。

-Help, -?, /?
    このメッセージを表示します。Windows PowerShell で PowerShell.exe のコマン
    ドを入力する場合、コマンド パラメーターの前にスラッシュ (/) ではなくハイ
    フン (-) を入力してください。Cmd.exe では、ハイフンまたはスラッシュのいずれかを使用できます。

例
    PowerShell -PSConsoleFile SqlSnapIn.Psc1
    PowerShell -version 2.0 -NoLogo -InputFormat text -OutputFormat XML
    PowerShell -ConfigurationName AdminRoles
    PowerShell -Command {Get-EventLog -LogName security}
    PowerShell -Command "& {Get-EventLog -LogName security}"

    # -EncodedCommand パラメーターを使用する場合:
    $command = 'dir "c:\program files" '
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
    $encodedCommand = [Convert]::ToBase64String($bytes)
    powershell.exe -encodedCommand $encodedCommand
#>