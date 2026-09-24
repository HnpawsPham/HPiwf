#include <EEPROM.h>
#include <Arduino.h>
#include <config.h>

void loadPref(){
    EEPROM.get(0, flameThreshold);
    EEPROM.get(sizeof(int), gasThreshold);
    
    if(flameThreshold == -1 || flameThreshold == 65535){
        flameThreshold = 100;
        gasThreshold = 100;
    }
}

void saveFlameThreshold(int val){
    flameThreshold = val;
    EEPROM.put(0, flameThreshold);
}

void saveGasThreshold(int val){
    gasThreshold = val;
    EEPROM.put(sizeof(int), gasThreshold);
}
