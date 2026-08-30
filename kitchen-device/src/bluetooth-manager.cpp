#include <config.h>
#include <Arduino.h>
#include <SoftwareSerial.h>

SoftwareSerial bluetooth(rxPin, txPin);

void initBT(){
    Serial.begin(9600);
    bluetooth.begin(9600);
    // name: kitchenDevice-HPiwf-23423
}

void sendSignal(String data){
    bluetooth.println(data);
}

void loopBT(){
    if(bluetooth.available())
        Serial.write(bluetooth.read());

    if(Serial.available())
        bluetooth.write(Serial.read());
}