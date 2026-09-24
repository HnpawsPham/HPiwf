#include <Arduino.h>
#include <config.h>
#include <mqtt-manager.h>
#include <bluetooth-manager.h>
#include <sensor-manager.h>

void setup(){
    Serial.begin(115200);
    
    connectWifi();
    delay(1000);
    initSensors();
    initBT();
}

unsigned long prevTime = 0;

void loop(){
    loopMQTT();
    loopBT();
    loopSensors();
}