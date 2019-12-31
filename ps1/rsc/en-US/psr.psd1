@{
    # For psr.exe en-US ToolTips.
    # see also : https://social.technet.microsoft.com/Forums/office/en-US/b78253b1-6e38-4563-9efa-4973414e9a75/problems-step-recorder-psrexe-command-line-options?forum=w7itprogeneral
    <#
    psr.exe [/start |/stop][/output <fullfilepath>] [/sc (0|1)] [/maxsc <value>]
        [/sketch (0|1)] [/slides (0|1)] [/gui (o|1)]
        [/arcetl (0|1)] [/arcxml (0|1)] [/arcmht (0|1)]
        [/stopevent <eventname>] [/maxlogsize <value>] [/recordpid <pid>]

    /start      :Start Recording. (Outputpath flag SHOULD be specified)
    /stop       :Stop Recording.
    /sc         :Capture screenshots for recorded steps.
    /maxsc      :Maximum number of recent screen captures.
    /maxlogsize :Maximum log file size (in MB) before wrapping occurs.
    /gui        :Display control GUI.
    /arcetl     :Include raw ETW file in archive output.
    /arcxml     :Include MHT file in archive output.
    /recordpid  :Record all actions associated with given PID.
    /sketch     :Sketch UI if no screenshot was saved.
    /slides     :Create slide show HTML pages.
    /output     :Store output of record session in given path.
    /stopevent  :Event to signal after output files are generated.
    #>
    '/start'      = '/start:Start Recording. (Outputpath flag SHOULD be specified)'
    '/stop'       = '/stop:Stop Recording.'
    '/sc'         = '/sc (0|1):Capture screenshots for recorded steps.'
    '/maxsc'      = '/maxsc <value>:Maximum number of recent screen captures.'
    '/maxlogsize' = '/maxlogsize <value>:Maximum log file size (in MB) before wrapping occurs.'
    '/gui'        = '/gui (0|1):Display control GUI.'
    '/arcetl'     = '/arcetl (0|1):Include raw ETW file in archive output.'
    '/arcxml'     = '/arcxml (0|1):Include MHT file in archive output.'
    '/recordpid'  = '/recordpid <pid>:Record all actions associated with given PID.'
    '/sketch'     = '/sketch (0|1):Sketch UI if no screenshot was saved.'
    '/slides'     = '/slides (0|1):Create slide show HTML pages.'
    '/output'     = '/output <filepath>:Store output of record session in given path.'
    '/stopevent'  = '/stopevent <eventname>:Event to signal after output files are generated.'

    # for /sc|gui|arcetl|arcxml|sketch|slides Switch.
    '0'           = 'disable switch.'
    '1'           = 'enable switch.'
}