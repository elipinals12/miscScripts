Dim Message, Speak, vol, a, b, d

b = 100

do
	Set WshShell = CreateObject("WScript.Shell")
	WshShell.SendKeys(chr(&hAE))
	b = b-2
loop until b = 0


vol=inputbox("Enter the volume percentage you want, make sure it is an even number" , "Volume")
a = vol/2




do
	
	Set WshShell = CreateObject("WScript.Shell")
	WshShell.SendKeys(chr(&hAF))
	a = a-1
	
loop until a = 0



Message = "reeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeediculous"
Set Speak=CreateObject("sapi.spvoice")
Speak.Speak Message