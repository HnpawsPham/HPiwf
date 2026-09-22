#include <Arduino.h>
#include <LittleFS.h>
#include <WiFi.h>
#include <config.h>
#include <PubSubClient.h>
#include <internet-manager.h>
#include <reminder.h>
#include <helper.h>

// mqtt communication
void callback(const char* topic, const byte* payload, unsigned int len){
    if(strstr(topic, "data/reminder") != nullptr){
        String mess = String((char*)(payload)).substring(0, len);

        speaker.connecttospeech(mess.c_str(), "vi");
        return;
    }
}

void publish(const char* topic, const char* payload){
    client.publish(GIDPrefix(topic), payload);
}

void subscribe(const char* topic){
    client.subscribe(GIDPrefix(topic));
}

void connectMQTT(){
    client.setClient(*networkClient);
    if(client.connect(wristbandName, MQTT_USERNAME, "")){
        Serial.println("Connected to broker");
        client.subscribe(GIDPrefix("data/setting"));
        client.subscribe(GIDPrefix("data/reminder"));
        client.publish("data", "esp32 hello");
    }
    else delay(1000);
}

void initMQTT(){
    if(networkClient == nullptr) 
        return;

    client.setServer(MQTT_SERVER, MQTT_PORT);
    client.setCallback(callback);
    connectMQTT();
}

void loopMQTT(){
    client.loop();

    if(!client.connected())
        connectMQTT();
}
