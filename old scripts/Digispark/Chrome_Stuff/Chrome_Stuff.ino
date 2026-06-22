#include "DigiKeyboard.h"


void setup() {
  DigiKeyboard.sendKeyStroke(0);
  
  
  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(100);
  DigiKeyboard.print("chrome\n");
  DigiKeyboard.delay(1000);
  DigiKeyboard.sendKeyStroke(KEY_L, MOD_CONTROL_LEFT);
  
  DigiKeyboard.print("https://codepen.io/murilopolese/full/xVaoQr\n");
  DigiKeyboard.delay(1000);
  DigiKeyboard.write("\t\t\t\t\t\t\t");
}


void loop()  {
  DigiKeyboard.print(" ");
}
