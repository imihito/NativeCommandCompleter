@{
    # For psr.exe ja-JP ToolTips
    # 日本語用ツールチップ文字列。
    # see also : https://social.technet.microsoft.com/Forums/office/en-US/b78253b1-6e38-4563-9efa-4973414e9a75/problems-step-recorder-psrexe-command-line-options?forum=w7itprogeneral
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

    # for /sc|gui|arcetl|arcxml|sketch|slides Switch.
    '0'           = '指定したスイッチを無効にします。'
    '1'           = '指定したスイッチを有効にします。'
}