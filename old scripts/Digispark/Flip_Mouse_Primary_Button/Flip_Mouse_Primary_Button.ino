#include "DigiKeyboard.h"

void setup() {
  // put your setup code here, to run once:
  DigiKeyboard.sendKeyStroke(0);

  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(250);
  DigiKeyboard.print("RUNDLL32 USER32.DLL,SwapMouseButton\n");
}

void loop() {
  // put your main code here, to run repeatedly:

}
