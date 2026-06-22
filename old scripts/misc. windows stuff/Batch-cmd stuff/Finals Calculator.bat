title Finals Calculator
color 0a
@echo off
set /p Q1=Type in your quarter one grade-
set /p Q2=Type in your quarter two grade-

set /p A1=Type in your desired average grade-
set /a exg=(%A1%-(((%Q1%+%Q2%)*4)/10))*5
echo %exg%

pause