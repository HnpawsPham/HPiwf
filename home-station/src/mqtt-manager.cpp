#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <config.h>
#include <ArduinoJson.h>
#include <bluetooth-manager.h>

WiFiClient esp32;
PubSubClient client(esp32);

void callback(const char* topic_ch, const byte* payload, unsigned int len){
    String topic = String(topic_ch);

    // adjust flame threshold
    if(topic == "data/setting/flame-threshold"){
        Serial.println((const char*)payload);
        sendData(KITCHEN_DEVICE_NAME, (const char*)payload);
    }
    // adjust gas threshold
    else if(topic == "data/setting/gas-threshold"){
        Serial.println((const char*)payload);
        sendData(KITCHEN_DEVICE_NAME, (const char*)payload);
    }
    // adjust ultrasound sensor detect range
    else if(topic == "data/setting/door-size"){
        JsonDocument doc;
        DeserializationError err = deserializeJson(doc, payload, len);

        if(!err){
            String limMin = "min:" + doc["min"].as<String>();
            String limMax = "max:" + doc["max"].as<String>();
            sendData(DOOR_DEVICE_NAME, limMin.c_str());
            sendData(DOOR_DEVICE_NAME, limMax.c_str());
        }
        else Serial.println("Json error");
    }
}

void connectWifi(){
    WiFi.begin(ssid, pass);

    while(WiFi.status() != WL_CONNECTED){
        Serial.print('.');
        delay(30);
    }
    Serial.println("Connected to Wifi");

    client.setServer(MQTT_SERVER, 1883);
    client.setCallback(callback);
}

void loopMQTT(){
    client.loop();

    if(!client.connected()){
        if(client.connect(STATION_DEVICE_NAME, MQTT_USERNAME, "")){
            Serial.println("Connected to broker");
            client.subscribe("data/setting/#");
        }
        else delay(1000);
    }
}

void publish(const char* topic, const float& payload){
    client.publish(topic, String(payload).c_str());
}

void subscribe(const char* topic){
    client.subscribe(topic);
}