#include <config.h>
#include <Arduino.h>
#include <SoftwareSerial.h>
#include <preference.h>

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
    if(bluetooth.available()){
        String data = bluetooth.readStringUntil('\n');
        Serial.println(data);

        if(data.startsWith("gas:")){
            gasThreshold = data.substring(4).toInt();
            saveGasThreshold(gasThreshold);
            sendSignal("received gas threshold");
        }
        if(data.startsWith("flame:")){
            flameThreshold = data.substring(6).toInt();
            saveFlameThreshold(flameThreshold);
            sendSignal("received flame threshold");
        }
    }
    if(Serial.available())
        bluetooth.write(Serial.read());
}