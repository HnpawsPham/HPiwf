#include <Arduino.h>
#include <LittleFS.h>
#include <WiFi.h>
#include <config.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <internet-manager.h>
#include <reminder.h>
#include <helper.h>
#include <Preferences.h>

// mqtt communication
void callback(const char* topic, const byte* payload, unsigned int len){
    if(strstr(topic, "data/reminder") != nullptr){
        JsonDocument doc;
        DeserializationError err = deserializeJson(doc, payload, len);
       
        // GET AND SAVE REMINDERS
        if(err) Serial.println("Json error");
        String data = String((char*)payload, len);

        if(doc["sleep"].isNull()){ //med
            pref.begin("reminder");
            reminderList = pref.getString("reminderList", "");
            
            if(reminderList.length() == 0)
                reminderList = "[" + data + "]"; 
            else{
                int sz = reminderList.length();
                reminderList.reserve(sz + data.length() + 2);
                reminderList = reminderList.substring(0, sz - 1) + "," + data + "]";
            }
            
            pref.putString("reminderList", reminderList);
            pref.end();
        }
        else{ //sleep 
            pref.begin("bedtime");
            bedtimeList = data;
            pref.putString("bedtimeList", bedtimeList);
            pref.end();
        }
        return;
    }

    if(strstr(topic, "data/del-reminder") != nullptr){
        JsonDocument doc;
        DeserializationError err = deserializeJson(doc, payload, len);
        if(err) return;

        if(!doc["time"].isNull()){ //med
            String time = doc["time"].as<String>();
            String name = doc["name"].as<String>();
            String cmd = "\"time\":\"" + time + "\"";

            int pos = 0;
            while((pos = reminderList.indexOf(cmd, pos)) != -1){
                int st = reminderList.lastIndexOf('{', pos);
                int en = reminderList.indexOf('}', pos);

                if(st != -1 && en != -1){
                    String s = reminderList.substring(st, en + 1);
                    if(s.indexOf("\"name\":\"" + name + "\"") != -1){
                 
                        if(st > 1 && reminderList[st - 1] == ',')
                            st--;
                        else if(en + 1 < reminderList.length() && reminderList[en + 1] == ',')
                            en++;
                        
                        reminderList.remove(st, en - st + 1);
                        
                        pref.begin("reminder");
                        pref.putString("reminderList", reminderList);
                        pref.end();
                        break;
                    }
                }
                pos++;
            }
        }
        else if(!doc["sleep"].isNull()){ //sleep
            bedtimeList = "";
            pref.begin("bedtime");
            pref.remove("bedtimeList");
            pref.end();
        }
    }

    if(strstr(topic, "data/setting/take-off-alert") != nullptr){
        if(len != 1) return;

        bool active = ((char)payload[0] == '1');
        if(active == TAKE_OFF_ALERT) 
            return;

        pref.begin("take-off-alert");
        pref.putBool("take-off-alert", active);
        pref.end();

        TAKE_OFF_ALERT = active;
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
    if(client.connect(wristbandName, MQTT_USERNAME, "", GIDPrefix("data/status/wristband"), 1, 1, "offline")){
        Serial.println("Connected to broker");
        client.publish(GIDPrefix("data/status/wristband"), "online", 1);
        client.subscribe(GIDPrefix("data/setting/take-off-alert"));
        client.subscribe(GIDPrefix("data/reminder"));
        client.subscribe(GIDPrefix("data/del-reminder"));
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
