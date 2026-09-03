#include <Arduino.h>
#include <LittleFS.h>
#include <mqtt-manager.h>
#include <pulse-proximity.h>
#include <internet-manager.h>
#include <mpu.h>
#include <gps.h>
#include <speaker.h>
#include <config.h>

void setup(){
    Serial.begin(115200);

    if(!LittleFS.begin(1))
        Serial.println("LittleFS error");

    // initialize components
    initInternet();

    delay(1000);
    initMQTT();

    initGPS();
    initHeartSensor();
    // initMPU();
    initSpeaker();
}

unsigned long prevTime = 0;

void loop(){
    speaker.loop();

    loopInternet();
    loopMQTT();
    loopGPS();
    loopHeartSensor();
    // loopMPU();
}