dim ws, message, speak

set ws = CreateObject("Wscript.shell")
Set wshShell = CreateObject( "WScript.Shell" )

Set Speak=CreateObject("sapi.spvoice")
Speak.Speak "One minute saver started"

do
	Set wshShell = CreateObject( "WScript.Shell" )
	strCmd = wshShell.ExpandEnvironmentStrings( "%COMSPEC% /C (TIMEOUT.EXE /T 60 /NOBREAK)" )
	wshShell.Run strCmd, 0, 1
	Set wshShell = Nothing

	Message = "Saving"
	
	Speak.Speak Message

	ws.Sendkeys "^s"
	
loop