Set WshShell = CreateObject("WScript.Shell")
do while n < 50
	n = n + 1
	WshShell.SendKeys(chr(&hAF))
loop