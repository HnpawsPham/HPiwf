#ifndef BLUETOOTH_MANAGER_H
#define BLUETOOTH_MANAGER_H

void initBT();
void getData(const char* senderName);
void sendData(const char* receiverName, const char* val);
void loopBT();

#endif