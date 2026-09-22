#include <config.h>
#include <Arduino.h>
#include <preference.h>
#include <SoftwareSerial.h>

SoftwareSerial bluetooth(rxPin, txPin);

void initBT(){
    bluetooth.begin(9600);
    // name: doorDevice-HPiwf-23423
}

void sendSignal(String data){
    bluetooth.println(data);
}

void loopBT(){
    if(bluetooth.available()){
        String data = bluetooth.readStringUntil(':');
        if(data == "door") {
            limMin = bluetooth.parseInt();
            limMax = bluetooth.parseInt();

            Serial.print("Min: ");
            Serial.print(limMin);
            Serial.print(" ; Max: ");
            Serial.println(limMax);

            sendSignal("received door setting");
            saveLimMin(limMin);
            saveLimMax(limMax);
        }
    }

    if(Serial.available())
        bluetooth.write(Serial.read());
}