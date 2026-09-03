#define TINY_GSM_MODEM_SIM7600

#include <Arduino.h>
#include <TinyGsmClient.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <mqtt-manager.h>
#include <config.h>

HardwareSerial simSerial(simHS);
TinyGsm sim(simSerial);
TinyGsmClient simClient(sim);

WiFiClient wifiClient;
PubSubClient client;
Client* networkClient = nullptr;
bool CONNECTION_MODE = 0; // 0: wifi, 1: 5g

const int RECONNECT_TRY = 5;

// house internet
bool connectWifi(){
    WiFi.begin(ssid, pass);

    int cnt = 0;
    while(WiFi.status() != WL_CONNECTED && cnt < RECONNECT_TRY){
        Serial.print('.');
        delay(500);
        cnt++;
    }

    if(WiFi.status() == WL_CONNECTED){
        networkClient = &wifiClient;
        sim.gprsDisconnect();

        Serial.println("Connected to wifi");
        CONNECTION_MODE = 0;
        return 1;
    }
    return 0;
}

// sim internet
int apnID = 0;
void connect5G(){
    Serial.println("Connected to Wifi failed, switch to 5g sim");

    simSerial.begin(115200, SERIAL_8N1, simRX, simTX);
    delay(1000);

    sim.restart();

    while(!sim.waitForNetwork()){
        Serial.print('.');
        delay(10);
    }
    Serial.println("Network found");

    while(1){
        Serial.print("Trying apn ");
        Serial.println(apns[apnID]);

        sim.gprsDisconnect();
        delay(1000);

        if(sim.gprsConnect(apns[apnID], "", ""))
            break;
        else{
            Serial.println("GPRS failed");
            apnID = (apnID + 1) % 4;
            delay(3000);
        }
    }

    Serial.println("Connected to 5G");
    CONNECTION_MODE = 1;
    networkClient = &simClient;
}

void initInternet(){    
    if(!connectWifi())
        connect5G();
}

unsigned long lastWifiRetry = 0;
const unsigned long WIFI_RETRY_WAITTIME = 60000;

void loopInternet(){
    unsigned long prevTime = 0;

    if(millis() - prevTime > 200){
        prevTime = millis();

        // try to connect to wifi, if fail connect 5g
        if(networkClient == &wifiClient){
            if(WiFi.status() != WL_CONNECTED)
                initInternet();
        }
        else{
            if(!sim.isGprsConnected())
                sim.gprsConnect(apns[apnID], "", "");

            // to save sim data
            if(millis() - lastWifiRetry > WIFI_RETRY_WAITTIME){
                lastWifiRetry = millis();
                connectWifi();
            }
        }
    }
}