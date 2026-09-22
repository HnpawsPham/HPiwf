#include <EEPROM.h>
#include <Arduino.h>
#include <config.h>

void loadPref(){
    EEPROM.get(0, limMin);
    EEPROM.get(sizeof(int), limMax);
    
    if(limMin == -1 || limMax == 65535){
        limMin = 5;
        limMax = 20;
    }
}

void saveLimMin(int val){
    limMin = val;
    EEPROM.put(0, limMin);
}

void saveLimMax(int val){
    limMax = val;
    EEPROM.put(sizeof(int), limMax);
}
