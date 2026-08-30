#include <Arduino.h>
#include <data-transfer.h>
#include <pulse-proximity.h>
#include <internet-manager.h>
#include <mpu.h>
#include <gps.h>
#include <speaker.h>

void setup(){
    Serial.begin(115200);

    // initialize components
    initInternet();
    initGPS();
    initMQTT();
    initHeartSensor();
    // initMPU();
    initSpeaker();
}

unsigned long prevTime = 0;

void loop(){
    speaker.loop();

    loopGPS();
    loopInternet();
    loopMQTT();
    loopHeartSensor();
    // loopMPU();
}