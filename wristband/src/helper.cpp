#include <Arduino.h>
#include <LittleFS.h>
#include <ArduinoHttpClient.h>
#include <internet-manager.h>
#include <config.h>

// get topic with GID (GID + topic)
char topicBuffer[40];
const char* GIDPrefix(const char* topic){
    snprintf(topicBuffer, sizeof topicBuffer, "%s/%s", GID, topic);
    return topicBuffer;
}

// handle sim5G download google text to speech 
HttpClient http(simClient, "translate.google.com", 80); 

String urlEncode(String s){
    String res = "";
    char c, code[4];
    int n = s.length();

    for(int i = 0; i < n; i++){
        c = s.charAt(i);

        if(isalnum(c)) res += c;
        else{
            sprintf(code, "%%%02X", (unsigned char)c);
            res += code;
        }
    }
    return res;
}

bool downloadTTS(String text){
    http.get("/translate_tts?ie=UTF-8&client=tw-ob&tl=vi&q=" + urlEncode(text));
    if(http.responseStatusCode() != 200){
        http.stop(); 
        return 0;
    }

    File f = LittleFS.open("/tmp.mp3", FILE_WRITE);
    while(http.connected() || http.available())
        while(http.available()) f.write(http.read());
        
    f.close(); 
    http.stop();
    return 1;
}