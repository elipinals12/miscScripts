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
cd !clas!
del all.html
rmdir /s /q pages
md pages
cd images
cd small

for %%i in (*.JPG) do (
    echo ^<a href="pages/%%~ni.html"^>
    echo 	^<img class="display-img disabledrag disableselect" oncontextmenu="return false;" alt="!clas! pics" src="images/small/%%i"/^>
    echo ^</a^>
) >> ../../all.html

set /a num=0
for %%i in (*.JPG) do (
	set /a num+=1
)

set /a count=1
for %%i in (*.JPG) do (
	set /a plus=!count!+1
	set /a minus=!count!-1
    (
		echo ^<html^>
		echo 	^<head^>
		echo 		^<meta name="viewport" content="width=device-width, initial-scale=1"^>
		echo 		^<link rel="stylesheet" type="text/css" href="../../style.css"^>
		echo 		^<title^>GOLDA~Image^</title^>
		echo 		^<link rel="icon" href="../../images/golda_logo.png"^>
		echo 	^</head^>
		echo 	^<header^>
		echo 		^<nav class="topnav"^>
		echo 			^<a href="../../index.html"^>Home^</a^>
	) >> ../../pages/%%~ni.html
	
	if !clas!==pottery (
		echo 			^<a class="active" href="../../pottery/pottery.html"^>Ceramics^</a^>
		echo 			^<a href="../../drawing/drawing.html"^>Drawings and Paintings^</a^>
		echo 			^<a href="../../photograph/photograph.html"^>Photography^</a^>
		echo 			^<a href="../../zine/zine.html"^>Zine^</a^>
		echo 			^<a href="../../sculpture/sculpture.html"^>Sculptures^</a^>
		echo 			^<a href="../../print/print.html"^>Prints^</a^>
		echo 			^<a href="../../jewelry/jewelry.html"^>Jewelry^</a^>
	) >> ../../pages/%%~ni.html
	
	if !clas!==drawing (
		echo 			^<a href="../../pottery/pottery.html"^>Ceramics^</a^>
		echo 			^<a class="active" href="../../drawing/drawing.html"^>Drawings and Paintings^</a^>
		echo 			^<a href="../../photograph/photograph.html"^>Photography^</a^>
		echo 			^<a href="../../zine/zine.html"^>Zine^</a^>
		echo 			^<a href="../../sculpture/sculpture.html"^>Sculptures^</a^>
		echo 			^<a href="../../print/print.html"^>Prints^</a^>
		echo 			^<a href="../../jewelry/jewelry.html"^>Jewelry^</a^>
	) >> ../../pages/%%~ni.html
	
	if !clas!==photograph (
		echo 			^<a href="../../pottery/pottery.html"^>Ceramics^</a^>
		echo 			^<a href="../../drawing/drawing.html"^>Drawings and Paintings^</a^>
		echo 			^<a class="active" href="../../photograph/photograph.html"^>Photography^</a^>
		echo 			^<a href="../../zine/zine.html"^>Zine^</a^>
		echo 			^<a href="../../sculpture/sculpture.html"^>Sculptures^</a^>
		echo 			^<a href="../../print/print.html"^>Prints^</a^>
		echo 			^<a href="../../jewelry/jewelry.html"^>Jewelry^</a^>
	) >> ../../pages/%%~ni.html
	
	if !clas!==zine (
		echo 			^<a href="../../pottery/pottery.html"^>Ceramics^</a^>
		echo 			^<a href="../../drawing/drawing.html"^>Drawings and Paintings^</a^>
		echo 			^<a href="../../photograph/photograph.html"^>Photography^</a^>
		echo 			^<a class="active" href="../../zine/zine.html"^>Zine^</a^>
		echo 			^<a href="../../sculpture/sculpture.html"^>Sculptures^</a^>
		echo 			^<a href="../../print/print.html"^>Prints^</a^>
		echo 			^<a href="../../jewelry/jewelry.html"^>Jewelry^</a^>
	) >> ../../pages/%%~ni.html
	
	if !clas!==sculpture (
		echo 			^<a href="../../pottery/pottery.html"^>Ceramics^</a^>
		echo 			^<a href="../../drawing/drawing.html"^>Drawings and Paintings^</a^>
		echo 			^<a href="../../photograph/photograph.html"^>Photography^</a^>
		echo 			^<a href="../../zine/zine.html"^>Zine^</a^>
		echo 			^<a class="active" href="../../sculpture/sculpture.html"^>Sculptures^</a^>
		echo 			^<a href="../../print/print.html"^>Prints^</a^>
		echo 			^<a href="../../jewelry/jewelry.html"^>Jewelry^</a^>
	) >> ../../pages/%%~ni.html
	
	if !clas!==print (
		echo 			^<a href="../../pottery/pottery.html"^>Ceramics^</a^>
		echo 			^<a href="../../drawing/drawing.html"^>Drawings and Paintings^</a^>
		echo 			^<a href="../../photograph/photograph.html"^>Photography^</a^>
		echo 			^<a href="../../zine/zine.html"^>Zine^</a^>
		echo 			^<a href="../../sculpture/sculpture.html"^>Sculptures^</a^>
		echo 			^<a class="active" href="../../print/print.html"^>Prints^</a^>
		echo 			^<a href="../../jewelry/jewelry.html"^>Jewelry^</a^>
	) >> ../../pages/%%~ni.html
	
	if !clas!==jewelry (
		echo 			^<a href="../../pottery/pottery.html"^>Ceramics^</a^>
		echo 			^<a href="../../drawing/drawing.html"^>Drawings and Paintings^</a^>
		echo 			^<a href="../../photograph/photograph.html"^>Photography^</a^>
		echo 			^<a href="../../zine/zine.html"^>Zine^</a^>
		echo 			^<a href="../../sculpture/sculpture.html"^>Sculptures^</a^>
		echo 			^<a href="../../print/print.html"^>Prints^</a^>
		echo 			^<a class="active" href="../../jewelry/jewelry.html"^>Jewelry^</a^>
	) >> ../../pages/%%~ni.html
	
	(
		echo 			^<a href="../../contact.html"^>Contact and Bio^</a^>
		echo 		^</nav^>
		echo 	^</header^>
		echo 	^<body bgcolor=#000000^>
	) >> ../../pages/%%~ni.html
	
	if !count! LEQ 8 (
		if !count! NEQ 1 (
			if !count! NEQ !num! (
				echo 		^<form action="../../!clas!/pages/!clas!-0!plus!.html"^>
				echo 			^<button class="right-btn disableselect"^>^&#10093^</button^>
				echo 		^</form^>
				echo 		^<form action="../../!clas!/pages/!clas!-0!minus!.html"^>
				echo 			^<button class="left-btn disableselect"^>^&#10092^</button^>
				echo 		^</form^>
			) >> ../../pages/%%~ni.html
		)
		if !count! EQU 1 (
			echo 		^<form action="../../!clas!/pages/!clas!-0!plus!.html"^>
			echo 			^<button class="right-btn disableselect"^>^&#10093^</button^>
			echo 		^</form^>
			echo 		^<button class="left-btn disableselect" id="greyed"^>^&#10092^</button^>
		) >> ../../pages/%%~ni.html
		if !count! EQU !num! (
			echo 		^<button class="right-btn disableselect" id="greyed"^>^&#10093^</button^>
			echo 		^<form action="../../!clas!/pages/!clas!-0!minus!.html"^>
			echo 			^<button class="left-btn disableselect"^>^&#10092^</button^>
			echo 		^</form^>
		) >> ../../pages/%%~ni.html
	)
	
	if !count! EQU 9 (
		if !count! NEQ 1 (
			if !count! NEQ !num! (
				echo 		^<form action="../../!clas!/pages/!clas!-!plus!.html"^>
				echo 			^<button class="right-btn disableselect"^>^&#10093^</button^>
				echo 		^</form^>
				echo 		^<form action="../../!clas!/pages/!clas!-0!minus!.html"^>
				echo 			^<button class="left-btn disableselect"^>^&#10092^</button^>
				echo 		^</form^>
			) >> ../../pages/%%~ni.html
		)
		if !count! EQU 1 (
			echo 		^<form action="../../!clas!/pages/!clas!-!plus!.html"^>
			echo 			^<button class="right-btn disableselect"^>^&#10093^</button^>
			echo 		^</form^>
			echo 		^<button class="left-btn disableselect" id="greyed"^>^&#10092^</button^>
		) >> ../../pages/%%~ni.html
		if !count! EQU !num! (
			echo 		^<button class="right-btn disableselect" id="greyed"^>^&#10093^</button^>
			echo 		^<form action="../../!clas!/pages/!clas!-0!minus!.html"^>
			echo 			^<button class="left-btn disableselect"^>^&#10092^</button^>
			echo 		^</form^>
		) >> ../../pages/%%~ni.html
	)
	
	if !count! EQU 10 (
		if !count! NEQ 1 (
			if !count! NEQ !num! (
				echo 		^<form action="../../!clas!/pages/!clas!-!plus!.html"^>
				echo 			^<button class="right-btn disableselect"^>^&#10093^</button^>
				echo 		^</form^>
				echo 		^<form action="../../!clas!/pages/!clas!-0!minus!.html"^>
				echo 			^<button class="left-btn disableselect"^>^&#10092^</button^>
				echo 		^</form^>
			) >> ../../pages/%%~ni.html
		)
		if !count! EQU 1 (
			echo 		^<form action="../../!clas!/pages/!clas!-!plus!.html"^>
			echo 			^<button class="right-btn disableselect"^>^&#10093^</button^>
			echo 		^</form^>
			echo 		^<button class="left-btn disableselect" id="greyed"^>^&#10092^</button^>
		) >> ../../pages/%%~ni.html
		if !count! EQU !num! (
			echo 		^<button class="right-btn disableselect" id="greyed"^>^&#10093^</button^>
			echo 		^<form action="../../!clas!/pages/!clas!-0!minus!.html"^>
			echo 			^<button class="left-btn disableselect"^>^&#10092^</button^>
			echo 		^</form^>
		) >> ../../pages/%%~ni.html
	)
	
	if !count! GEQ 11 (
		if !count! NEQ 1 (
			if !count! NEQ !num! (
				echo 		^<form action="../../!clas!/pages/!clas!-!plus!.html"^>
				echo 			^<button class="right-btn disableselect"^>^&#10093^</button^>
				echo 		^</form^>
				echo 		^<form action="../../!clas!/pages/!clas!-!minus!.html"^>
				echo 			^<button class="left-btn disableselect"^>^&#10092^</button^>
				echo 		^</form^>
			) >> ../../pages/%%~ni.html
		)
		if !count! EQU 1 (
			echo 		^<form action="../../!clas!/pages/!clas!-!plus!.html"^>
			echo 			^<button class="right-btn disableselect"^>^&#10093^</button^>
			echo 		^</form^>
			echo 		^<button class="left-btn disableselect" id="greyed"^>^&#10092^</button^>
		) >> ../../pages/%%~ni.html
		if !count! EQU !num! (
			echo 		^<button class="right-btn disableselect" id="greyed"^>^&#10093^</button^>
			echo 		^<form action="../../!clas!/pages/!clas!-!minus!.html"^>
			echo 			^<button class="left-btn disableselect"^>^&#10092^</button^>
			echo 		^</form^>
		) >> ../../pages/%%~ni.html
	)
	
	(
		echo 		^<img class="big-img disabledrag disableselect" oncontextmenu="return false;" src="../images/big/%%i" alt="%%i Enlarged"^>
		echo 		^<form action="../../!clas!/!clas!.html"^>
		echo 			^<button class="back-btn" type="submit"^>^&#10094^&#10094 Go Back^</button^>
		echo 		^</form^>
		echo 	^</body^>
		echo 	^<footer^>
		echo 		^<small class="right-align"^>Copyright ^&copy;
		echo			^<script^>
		echo				document.write^(new Date^(^).getFullYear^(^)^)
		echo			^</script^>
		echo			Golda Pinals. All Rights Reserved
		echo		^</small^>
		echo 	^</footer^>
		echo ^</html^>
	) >> ../../pages/%%~ni.html
	set /a count+=1
)

cd ../../..

set /a run+=1
goto !run!