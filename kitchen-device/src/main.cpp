#include <Arduino.h>
#include <config.h>
#include <bluetooth-manager.h>
#include <SoftwareSerial.h>

void setup(){
    initBT();

    pinMode(gasPin, INPUT);
    pinMode(flamePin, INPUT);
}

unsigned long prevTime = 0;

void checkGas(){
    int gasVal = analogRead(gasPin);

    if(gasVal > gasThreshold){
        Serial.print("Gas warning! ");
        sendSignal("gas detected");
        Serial.println(gasVal);
    }
}

void checkFlame(){
    int flameVal = analogRead(flamePin);  

    if(flameVal < flameThreshold){
        Serial.print("Flame warning! ");
        sendSignal("flame detected");
        Serial.println(flameVal);
    }
}

void loop(){
    loopBT();

    if(millis() - prevTime > 700){
        prevTime = millis();

        checkGas();
        checkFlame();
    }
}