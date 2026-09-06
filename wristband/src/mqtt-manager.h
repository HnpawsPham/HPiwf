#ifndef MQTT_MANAGER_H
#define MQTT_MANAGER_H

void publish(const char* topic, const char* payload);
void callback(const char* topic_ch, const byte* payload, unsigned int len);
void subscribe(const char* topic);

void initMQTT();
void connectMQTT();
void loopMQTT();

#endif