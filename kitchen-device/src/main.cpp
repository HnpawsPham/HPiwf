#include <Arduino.h>
#include <config.h>
#include <bluetooth-manager.h>
#include <SoftwareSerial.h>
#include <preference.h>

void setup(){
    initBT();
    loadPref();

    pinMode(gasPin, INPUT);
    pinMode(flamePin, INPUT);
}

int minGasVal = 4095, maxGasVal = 0;

void checkGas(){
    static unsigned long prevGasTime = 0;

    int gasVal = analogRead(gasPin);  
    minGasVal = min(minGasVal, gasVal);
    maxGasVal = max(maxGasVal, gasVal);
    
    // Serial.println(String(minGasVal) + " " + String(maxGasVal));

    if(millis() - prevGasTime >= 5000){
        if(maxGasVal - minGasVal >= gasThreshold){
            Serial.print("gas warning! ");
            sendSignal("gas");
        }
        Serial.print("gas: ");
        Serial.println(maxGasVal - minGasVal);
        // sendSignal("gas: " + String(maxGasVal - minGasVal));
        maxGasVal = 0;
        minGasVal = 4095;
        prevGasTime = millis();
    }
}

int minFlameVal = 4095, maxFlameVal = 0;

void checkFlame(){
    static unsigned long prevFlameTime = 0;

    int flameVal = analogRead(flamePin);  
    minFlameVal = min(minFlameVal, flameVal);
    maxFlameVal = max(maxFlameVal, flameVal);
    
    // Serial.println(String(minFlameVal) + " " + String(maxFlameVal));

    if(millis() - prevFlameTime >= 3000){
        if(maxFlameVal - minFlameVal >= flameThreshold){
            Serial.print("Flame warning! ");
            sendSignal("flame");
        }
        Serial.print("flame: ");
        Serial.println(maxFlameVal - minFlameVal);

        maxFlameVal = flameVal;
        minFlameVal = flameVal;
        prevFlameTime = millis();
    }
}

unsigned long prevTime = 0;

void loop(){
    loopBT();

    if(millis() - prevTime > 100){
        prevTime = millis();

        checkGas();
        checkFlame();
    }
}