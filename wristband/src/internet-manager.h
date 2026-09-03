#ifndef INTERNET_MANAGER_H
#define INTERNET_MANAGER_H

#define TINY_GSM_MODEM_SIM800
#include <TinyGsmClient.h>
#include <PubSubClient.h>

extern PubSubClient client;
extern Client* networkClient;
extern bool CONNECTION_MODE;
extern TinyGsmClient simClient;

void initInternet();
void loopInternet();
bool downloadTTS(String text);

#endif