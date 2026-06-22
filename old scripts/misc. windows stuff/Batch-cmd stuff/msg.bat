@echo off
:r
set /p cpn="What computer number would you like to message>"
set /p msg="Write your message here>"
shutdown /s /m \\HUR-4201-%cpn% /t 600 /c "%msg%"
:a
set /p yon="Would you like to send another message? (Y or N)>"
if %yon%==N goto k
if %yon%==n goto k
if %yon%==Y goto r
if %yon%==y goto r
echo Type in N or Y
goto a
:k
shutdown /a /m \\HUR-4201-%cpn%
pause