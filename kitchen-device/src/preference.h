#ifndef PREFERENCE_H
#define PREFERENCE_H

#include <EEPROM.h>

void loadPref();
void saveFlameThreshold(int val);
void saveGasThreshold(int val);

#endif