#ifndef BLUETOOTH_MANAGER_H
#define BLUETOOTH_MANAGER_H

void initBT();
void loopBT();
bool sendData(const char* receiverName, const char* val);

#endif