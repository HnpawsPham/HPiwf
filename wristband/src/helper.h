#ifndef HELPER_H
#define HELPER_H

#include <ArduinoHttpClient.h>

extern HttpClient http; 
extern char topicBuffer[50];

const char* GIDPrefix(const char* topic);
String urlEncode(String s);
bool downloadTTS(String text);

#endif