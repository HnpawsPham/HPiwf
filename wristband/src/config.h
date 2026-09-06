#ifndef CONFIG_H
#define CONFIG_H

#include <secrets.h>

inline const char* wristbandName = "HPiwf-wristband283947";

// pinouts
inline const int blckPin = 27;
inline const int lrcPin = 14;
inline const int dinPin = 32;

inline const int sdaPin = 21;
inline const int sclPin = 22;

inline const int gpsRX = 25;
inline const int gpsTX = 26;

inline const int simRX = 16;
inline const int simTX = 17;

// hardware serials
inline const int gpsHS = 1;
inline const int simHS = 2;

// 5G
inline const char* apns[] = {
    "v-internet", // Viettel, Vietnamobile, iTel
    "m-wap",      // MobiFone
    "m3-world",   // Vinaphone, Wintel
    "internet"    // Gmobile
};
#endif