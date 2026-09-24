#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <config.h>
#include <ArduinoJson.h>
#include <bluetooth-manager.h>
#include <helper.h> 

WiFiClient esp32;
PubSubClient client(esp32);

void publish(const char* topic, const char* payload){
    client.publish(GIDPrefix(topic), payload);
}

void publish(const char* topic, const float& value){
    client.publish(GIDPrefix(topic), String(value).c_str());
}

void subscribe(const char* topic){
    client.subscribe(GIDPrefix(topic));
}

void callback(const char* topic, const byte* payload, unsigned int len){
    char val[len + 1];
    memcpy(val, payload, len);
    val[len] = '\0';

    // adjust flame threshold
    if(strstr(topic, "data/setting/flame-threshold") != nullptr){
        Serial.println((const char*)payload);
        if(!sendData(KITCHEN_DEVICE_NAME, ("flame:" + String(val)).c_str()))
            publish("data/notification/connection", "Set new flame threshold failed.");
    }
    // adjust gas threshold
    else if(strstr(topic, "data/setting/gas-threshold") != nullptr){
        Serial.println((const char*)payload);
        if(!sendData(KITCHEN_DEVICE_NAME, ("gas:" + String(val)).c_str()))
            publish("data/notification/connection", "Set new gas threshold failed.");
    }
    // adjust ultrasound sensor detect range
    else if(strstr(topic, "data/setting/door-size") != nullptr){
        JsonDocument doc;
        DeserializationError err = deserializeJson(doc, payload, len);
        Serial.println("receive door setting ok");

        if(!err){
            String limMin = "min:" + doc["min"].as<String>();
            String limMax = "max:" + doc["max"].as<String>();
            
            String cmd = "door:" + limMin + ";" + limMax;
            if(!sendData(DOOR_DEVICE_NAME, cmd.c_str()))
                publish("data/notification/connection", "Set door thresholds failed");
        }
        else Serial.println("Json error");
    }
}

void connectWifi(){
    WiFi.begin(ssid, pass);

    while(WiFi.status() != WL_CONNECTED){
        Serial.print('.');
        delay(10);
    }
    Serial.println("Connected to Wifi");

    client.setServer(MQTT_SERVER, 1883);
    client.setCallback(callback);
}

void loopMQTT(){
    if(!client.connected()){
        if(client.connect(STATION_DEVICE_NAME, MQTT_USERNAME, "", GIDPrefix("data/status/home-station"), 1, 1, "offline")){
            Serial.println("Connected to broker");
            client.subscribe(GIDPrefix("data/setting/#"));
            client.publish(GIDPrefix("data/status/home-station"), "online", 1);
        }
        else Serial.println("connect to broker failed");
    }
    else client.loop();
}