Dim Message, Speak

Message=InputBox("Enter text below. What ever you type, the Computer will say out loud. Just so you know, the computer can not say things with emotion. Thank You!","Speak What was Typed")
Set Speak=CreateObject("sapi.spvoice")
Speak.Speak Message

Do

	Message=InputBox("Enter text here","Speak")
	If Message = "" Then
		wscript.quit
	End If
	
	Set Speak=CreateObject("sapi.spvoice")
	Speak.Speak Message
	
Loop