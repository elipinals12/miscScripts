cd "C:\users\elipi\desktop\golda's website\actual site fr no junk"

setlocal EnableDelayedExpansion


set run=0

:0
set clas=zine
goto go
:1
set clas=pottery
goto go
:2
set clas=photograph
goto go
:3
set clas=drawing
goto go
:4
set clas=print
goto go
:5
set clas=sculpture
goto go
:6
set clas=jewelry
goto go
:7
exit


:go
cd %clas%
rmdir /s /q images
md images
cd images
md big & md small
copy "C:\users\elipi\desktop\golda's website\Website Images\%clas%\*" ".\big" /y
copy "C:\users\elipi\desktop\golda's website\smallout\%clas%\*" ".\small" /y
cd ../..

set /a run+=1
goto !run!