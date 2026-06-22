cd "C:\users\elipi\desktop\golda's website\Website Images"

setlocal EnableDelayedExpansion

cd ..
rmdir /s /q smallout
md smallout
cd "Website Images"

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
cd !clas!

for %%i in (*.JPG) do (
	ren "%%i" !random!.jpg
)

set count=0
for %%f in (*.JPG) do (
	if !count! LSS 10 (
		ren %%f !clas!-0!count!.jpg
		set /a count+=1
	) ELSE (
		ren %%f !clas!-!count!.jpg
		set /a count+=1
	)
)

cd ..

set /a run+=1
goto !run!
