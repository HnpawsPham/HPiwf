#ifndef DATA_TRANSFER_H
#define DATA_TRANSFER_H

void publish(const char* topic, const char* payload);
void callback(const char* topic_ch, const byte* payload, unsigned int len);
void subscribe(const char* topic);
void loopMQTT();

#endif