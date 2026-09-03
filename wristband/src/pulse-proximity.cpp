#include <Arduino.h>
#include <MAX30105.h>
#include <heartRate.h>
#include <mqtt-manager.h>
#include <spo2_algorithm.h>
#include <config.h>
#include <helper.h>

MAX30105 heartSensor;

uint32_t redBuffer[100], irBuffer[100];
int i, beatCnt;

// SETUPS
void setupHeartBeat(){
    beatCnt = 0;
    heartSensor.wakeUp(); 
    heartSensor.setup();
    heartSensor.setPulseAmplitudeRed(0xFF);
}

void setupSPO2(){
    i = 0;
    heartSensor.wakeUp(); 
    heartSensor.setup(0x1F, 4, 2, 100, 411, 4096);
}

void setupSleep(){ 
    heartSensor.shutDown();
}

// HANDLING
void handleHeartbeat(){
    heartSensor.check();

    while(heartSensor.available()){
        if(checkForBeat(heartSensor.getFIFOIR()))
            beatCnt++;
        heartSensor.nextSample();
    }
}

void handleSPO2(){
    heartSensor.check();

    while(heartSensor.available()){
        redBuffer[i] = heartSensor.getFIFORed();
        irBuffer[i] = heartSensor.getFIFOIR();
        heartSensor.nextSample();
        i++;

        if(i >= 100){
            int32_t SPO2, heartRate;
            int8_t validSPO2, validHeartRate;

            maxim_heart_rate_and_oxygen_saturation(irBuffer, 100, redBuffer, &SPO2, &validSPO2, &heartRate, &validHeartRate);

            if(validSPO2){
                Serial.print("SPO2: ");
                Serial.println(SPO2);
                publish(GIDPrefix("data/health/spo2"), String(SPO2).c_str());
            }
            i = 0;
        }
    }
}

// INITALIZE AND USAGE
void initHeartSensor(){
    Wire.begin(sdaPin, sclPin);

    if(!heartSensor.begin(Wire, I2C_SPEED_FAST)){
        Serial.println("Heart sensor error");
        return;
    }
    setupHeartBeat();
}

const int duration = 30000;
int MODE = 0; //0: heartbeat, 1: sleep, 2: spo2, 3: sleep

void loopHeartSensor(){
    static unsigned long prevTime = 0;

    if(millis() - prevTime >= duration){
        prevTime = millis(); 
        
        if(MODE == 0){
            beatCnt *= 2;
            
            Serial.print("BPM: ");
            Serial.println(beatCnt);

            publish(GIDPrefix("data/health/bpm"), String(beatCnt).c_str());
            setupSleep();
        }
        else if(MODE == 1)
            setupSPO2();
    
        else if(MODE == 2)
            setupSleep();
        
        else if(MODE == 3)
            setupHeartBeat();
        
        MODE = (MODE + 1) % 4;
    }

    if(MODE == 0) handleHeartbeat();
    else if(MODE == 2) handleSPO2();
}