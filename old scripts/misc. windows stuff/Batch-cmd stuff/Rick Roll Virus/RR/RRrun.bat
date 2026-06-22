timeout /t 1 /nobreak

start C:\users\%username%\documents\RR\V100.vbs
start C:\Users\%username%\Documents\RR\RRD.mp4 /max
start C:\users\%username%\documents\RR\V100.vbs
timeout /t 60 /nobreak

start C:\users\%username%\documents\RR\V100.vbs
start C:\Users\%username%\Documents\RR\RRD.mp4 /max
timeout /t 80 /nobreak

start C:\users\%username%\documents\RR\V100.vbs
start C:\Users\%username%\Documents\RR\RRD.mp4 /max
start C:\users\%username%\documents\RR\V100.vbs
timeout /t 70 /nobreak

start C:\users\%username%\documents\RR\V100.vbs
start C:\Users\%username%\Documents\RR\RRD.mp4 /max
timeout /t 100 /nobreak

start C:\users\%username%\documents\RR\V100.vbs
start C:\Users\%username%\Documents\RR\RRD.mp4 /max
start C:\users\%username%\documents\RR\V100.vbs
timeout /t 30 /nobreak

:A
start C:\users\%username%\documents\RR\V100.vbs
timeout /t 20 /nobreak
start C:\users\%username%\documents\RR\V100.vbs
timeout /t 20 /nobreak
start C:\users\%username%\documents\RR\V100.vbs
timeout /t 90
goto A
exit