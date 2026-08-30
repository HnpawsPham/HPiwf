#ifndef MQTT_MANAGER_H
#define MQTT_MANAGER_H


void connectWifi();
void loopMQTT();
void publish(const char* topic, const float& val);
void subscribe(const char* topic);

#endif