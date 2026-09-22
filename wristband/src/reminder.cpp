#include <WiFiUdp.h>
#include <Arduino.h>
#include <NTPClient.h>
#include <mqtt-manager.h>
#include <Preferences.h>
#include <Audio.h>
#include <config.h>
#include <helper.h>

Audio speaker;
Preferences pref;

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 7 * 3600);

String reminderList = "";
String bedtimeList = "";
void initSpeaker(){
    speaker.setPinout(blckPin, lrcPin, dinPin);
    speaker.setVolume(17);
}

void initNTP(){
    timeClient.begin();

    pref.begin("reminder", true);
    pref.begin("bedtime", true);
    reminderList = pref.getString("reminderList", "");
    bedtimeList = pref.getString("bedtimeList", "");
    pref.end();
}

int lastMin = -1;

void remindDrinkMed(const char* time) {
    int pos = 0;
    while((pos = reminderList.indexOf(String("\"time\":\"") + time + "\"", pos)) != -1) {
        int namePos = reminderList.indexOf("\"name\":\"", pos);
        if(namePos == -1) continue;

        int st = namePos + 8;
        int en = reminderList.indexOf("\"", st);

        String medName = reminderList.substring(st, en); 
        speaker.connecttospeech(("Đã đến giờ uống thuốc " + medName).c_str(), "vi");
        publish(GIDPrefix("data/notification"), ("Medicine " + medName + " reminder was sent").c_str());
        pos += 10;
    }
}

void remindBedtime(const char* time) {
    if(bedtimeList.indexOf(String("\"sleep\":\"") + time + "\"") == -1) 
        return;
     
    int contentPos = bedtimeList.indexOf("\"content\":\"");
    if(contentPos != -1){
      int st = contentPos + 11;
      int en = bedtimeList.indexOf("\"", st);
      speaker.connecttospeech(bedtimeList.substring(st, en).c_str(), "vi");
    }
}

void loopNTP(){
    timeClient.update();

    int hr = timeClient.getHours();
    int min = timeClient.getMinutes();

    if(min == lastMin) return;
    
    char time[6];
    sprintf(time, "%02d:%02d", hr, min);
    
    if(!bedtimeList.isEmpty()){
        remindBedtime(time);
        publish(GIDPrefix("data/notification"), "Bedtime reminder was sent");
    
    if(!reminderList.isEmpty())
        remindDrinkMed(time);
    lastMin = min;
}