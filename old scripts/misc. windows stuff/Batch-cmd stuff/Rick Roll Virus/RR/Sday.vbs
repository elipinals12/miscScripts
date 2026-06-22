Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "C:\users\%username%\Documents\RR\Day.bat" & Chr(34), 0
Set WshShell = Nothing