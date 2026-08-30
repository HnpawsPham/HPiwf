#define TINY_GSM_MODEM_SIM800

#include <Arduino.h>
#include <TinyGsmClient.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <data-transfer.h>
#include <config.h>

const char* apn = "v-internet";

HardwareSerial simSerial(simHS);
TinyGsm sim(simSerial);
TinyGsmClient simClient(sim);

WiFiClient wifiClient;
PubSubClient client;
Client* networkClient = nullptr; 

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
        Serial.println("Connected to wifi");
        return 1;
    }
    return 0;
}

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

    while(!sim.gprsConnect(apn, "", "")){
        Serial.print(".");
        delay(10);
    }

    Serial.println("Connected to 5G");
    networkClient = &simClient;
}

void initInternet(){    
    if(!connectWifi())
        connect5G();
}

void initMQTT(){
    client.setClient(*networkClient);
    client.setServer(MQTT_SERVER, MQTT_PORT);
    client.setCallback(callback);

    Serial.println("Connected to broker");
}

void loopInternet(){
    // try to connect to wifi, if fail connect 5g
    if(networkClient == &wifiClient){
        if(WiFi.status() != WL_CONNECTED)
            initInternet();
    }
    else{
        if(!sim.isGprsConnected())
            sim.gprsConnect(apn, "", "");
    }
}