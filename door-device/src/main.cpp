#include <Arduino.h>
#include <config.h>
#include <bluetooth-manager.h>

void setup() {
    Serial.begin(9600);

    pinMode(vibratePin, INPUT);
    pinMode(buzzerPin, OUTPUT);
    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);

    initBT();
}

unsigned long prevTime = 0;
int limMin = 5, limMax = 20;
bool detected = 0;

void checkObstacle() {
    static unsigned long lastSend = 0;

    digitalWrite(trigPin, 0);
    delayMicroseconds(2);
    digitalWrite(trigPin, 1);
    delayMicroseconds(10);
    digitalWrite(trigPin, 0);

    long duration = pulseIn(echoPin, 1, 7000);
    long d = duration * 17 / 1000;

    if (limMin <= d && d <= limMax) {
        if(millis() - lastSend > 500){
            lastSend = millis();

            Serial.println("Obstacle detect");
            sendSignal("obstacle detected");
        }
        detected = 1;
    }
}

void checkVibration() {
    static unsigned long lastSend = 0;

    if (digitalRead(vibratePin) && !detected) {
        if(millis() - lastSend > 500){
            lastSend = millis();

            Serial.println("Vibration detect");
            sendSignal("vibration detected");
        }
        detected = 1;
    }
}

void loop() {
    loopBT();

    if (millis() - prevTime > 100) {
        prevTime = millis();
        detected = 0;

        checkObstacle();
        checkVibration();

        digitalWrite(buzzerPin, detected);
    }
}