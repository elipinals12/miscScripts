cd "C:\users\elipi\desktop\golda's website\smallout"

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
md %clas%


for %%i in (!clas!*.JPG) do (
	move /y "%%i" %clas%
)



set /a run+=1
goto !run!