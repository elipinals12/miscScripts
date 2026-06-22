dim x
x = 0
do
	Set WshShell = CreateObject("WScript.Shell")
	WshShell.SendKeys(chr(&hAF))
	x = x+1
loop until x = 100000