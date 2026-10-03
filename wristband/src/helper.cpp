#include <Arduino.h>
#include <config.h>

// get topic with GID (GID + topic)
char topicBuffer[100];
const char* GIDPrefix(const char* topic){
    snprintf(topicBuffer, sizeof topicBuffer, "%s/%s", GID, topic);
    return topicBuffer;
}
