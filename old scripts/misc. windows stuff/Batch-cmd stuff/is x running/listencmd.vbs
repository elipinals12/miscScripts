Option Explicit 
Dim ProcessPath,WshShell 
ProcessPath = "%Windir%\System32\cmd.exe" 
Set WshShell = CreateObject("WScript.Shell") 
If AppPrevInstance() Then  
    MsgBox "There is an existing proceeding !" & VbCrLF &_ 
    CommandLineLike(WScript.ScriptName),VbExclamation,"There is an existing proceeding !"     
    WScript.Quit    
Else  
    Do 
        Pause(8) ' Pause 8 seconds  
        If CheckProcess(DblQuote(ProcessPath)) = False Then 
            Call Logoff()  
        End If   
    Loop 
End If 
'************************************************************************** 
Function CheckProcess(ProcessPath) 
    Dim strComputer,objWMIService,colProcesses,Tab,ProcessName 
    strComputer = "." 
    Tab = Split(ProcessPath,"\") 
    ProcessName = Tab(UBound(Tab)) 
    ProcessName = Replace(ProcessName,Chr(34),"") 
    Set objWMIService = GetObject("winmgmts:" _ 
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
    Set colProcesses = objWMIService.ExecQuery _ 
    ("Select * from Win32_Process Where Name = '"& ProcessName & "'") 
    If colProcesses.Count = 0 Then 
        CheckProcess = False 
    Else 
        CheckProcess = True 
    End if 
End Function 
'************************************************************************** 
Function DblQuote(Str) 
    DblQuote = Chr(34) & Str & Chr(34) 
End Function 
'************************************************************************** 
Sub Logoff() 
    Dim ws,Command,Execution 
    Set ws = CreateObject("wscript.Shell") 
    Command = "Cmd /c shutdown.exe -L -F" 
    Execution = ws.run(Command,0,True) 
End sub 
'************************************************************************** 
Sub Pause(Secs)     
    Wscript.Sleep(Secs * 1000)     
End Sub    
'************************************************************************** 
Function AppPrevInstance()    
    With GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")    
        With .ExecQuery("SELECT * FROM Win32_Process WHERE CommandLine LIKE " & CommandLineLike(WScript.ScriptFullName) & _ 
            " AND CommandLine LIKE '%WScript%' OR CommandLine LIKE '%cscript%'")    
            AppPrevInstance = (.Count > 1)    
        End With    
    End With    
End Function     
'*************************************************************************** 
Function CommandLineLike(ProcessPath)    
    ProcessPath = Replace(ProcessPath, "\", "\\")    
    CommandLineLike = "'%" & ProcessPath & "%'"    
End Function 
'****************************************************************************
