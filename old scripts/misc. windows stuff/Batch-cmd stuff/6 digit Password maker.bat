color 0a
@echo off
title 6 digit Password Maker
cls
set /a trynumber=0

:C
echo This should reset your password to the following things:
echo 1. Phone
echo 2. Laptop
echo 3. Desktop
echo 4. Bank Pin
pause
cls

:A
Echo testing...

set /a trynumber=%trynumber%+1

set /a num=%random% * %random%

if %num% GTR 999999 goto B
if %num% LSS 100000 goto B

cls
echo ---------------------------------------------------------------------------------------------
echo SUCCESS on Try Number %trynumber%
echo ---------------------------------------------------------------------------------------------
echo Showing passwod in hidden page next
echo ---------------------------------------------------------------------------------------------
pause
cls

echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %num%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%
echo %random%

pause
exit

:B
echo FAIL
echo             Try Number %trynumber%
goto A