#include <Arduino.h>
#include <mqtt-manager.h>
#include <pulse-proximity.h>
#include <internet-manager.h>
#include <mpu.h>
#include <gps.h>
#include <config.h>
#include <reminder.h>

void setup(){
    Serial.begin(115200);

    // initialize components
    initGPS();
    delay(1000);

    // initHeartSensor();
    // delay(500);

    initMPU();
    initSpeaker();
    delay(1000);

    initInternet();
    initMQTT();

    delay(1000);
    initNTP();

    pref.begin("take-off-alert");
    TAKE_OFF_ALERT = pref.getBool("take-off-alert", 1);
    pref.end();
}

unsigned long prevTime = 0;

void loop(){
    speaker.loop();

    loopInternet();
    loopMQTT();
    loopGPS();
    // loopHeartSensor();
    loopMPU();
    loopNTP();
}