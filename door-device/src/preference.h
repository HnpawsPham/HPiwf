#ifndef PREFERENCE_H
#define PREFERENCE_H

#include <EEPROM.h>

void loadPref();
void saveLimMin(int val);
void saveLimMax(int val);

#endif