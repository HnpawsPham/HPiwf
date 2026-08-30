#include <Arduino.h>
#include <WiFi.h>
#include <config.h>
#include <PubSubClient.h>
#include <internet-manager.h>
#include <speaker.h>

const char* wristbandName = "HPiwf-wristband283947";

// mqtt communication
void callback(const char* topic_ch, const byte* payload, unsigned int len){
    String topic = String(topic_ch);

    if(topic == "data/reminder"){
        String mess = String((char*)(payload)).substring(0, len);
        Serial.write(payload, len);

        speaker.connecttospeech(mess.c_str(), "vi");
    }
}

void publish(const char* topic, const char* payload){
    client.publish(topic, payload);
}

void subscribe(const char* topic){
    client.subscribe(topic);
}

void loopMQTT(){
    client.loop();

    if(!client.connected()){
        if(client.connect(wristbandName, MQTT_USERNAME, "")){
            Serial.println("Connected to broker");
            client.subscribe("data/setting");
            client.subscribe("data/reminder");
        }
        else delay(1000);
    }
}
