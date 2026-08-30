#ifndef CONFIG_H
#define CONFIG_H

#include <secrets.h>

inline const char* ssid = WIFI_SSID;
inline const char* pass = WIFI_PASS;

inline const char* MQTT_SERVER = mqttServer;
inline const char* MQTT_USERNAME = mqttUsername;

// bluetooth devices
inline const char* STATION_DEVICE_NAME = "stationDevice-HPiwf-23423";
inline const char* DOOR_DEVICE_NAME = "doorDevice-HPiwf-23423";
inline const char* KITCHEN_DEVICE_NAME = "kitchenDevice-HPiwf-23423";

// Pins
inline const int dhtPin = 18;
inline const int rainPin = 35;
inline const int airQualityPin = 33;
inline const int noisePin = 34;
#endif