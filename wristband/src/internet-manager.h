#ifndef INTERNET_MANAGER_H
#define INTERNET_MANAGER_H

#define TINY_GSM_MODEM_SIM800
#include <TinyGsmClient.h>
#include <PubSubClient.h>

extern PubSubClient client;

void initInternet();
void initMQTT();
void loopInternet();

#endif