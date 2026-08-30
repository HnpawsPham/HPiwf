#include <config.h>
#include <Arduino.h>
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
        String data = bluetooth.readStringUntil('\n');
        Serial.println(data);
    }

    if(Serial.available())
        bluetooth.write(Serial.read());
}