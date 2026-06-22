color 0a
@echo off
title Pin Maker
cls
:C
set /p gm="TYPE GO HERE>>>>> "
if %gm% == GO goto A
if %gm% == go goto A
if %gm% == Go goto A
if %gm% == G0 goto A
if %gm% == g0 goto A

goto C

:A
set /a num=%random% + 1
echo Testing...
timeout /t 1 /nobreak
if %num% GTR 9999 goto B
if %num% LSS 1000 goto B

echo %random%
echo %num%
set /a num=%random%
echo %num%
echo %num%
timeout /t 5 /NOBREAK
exit
exit
exit
exit
exit
exit

:B
echo FAIL

goto A

exit
exit
exit
exit
exit