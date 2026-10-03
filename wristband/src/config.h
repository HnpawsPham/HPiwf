#ifndef CONFIG_H
#define CONFIG_H

#include <secrets.h>
#include <Preferences.h>

inline Preferences pref;
inline bool TAKE_OFF_ALERT = 1;

inline const char* const wristbandName = "HPiwf-wristband283947";

// pinouts
inline const int blckPin = 19;
inline const int lrcPin = 18;
inline const int dinPin = 23;

inline const int sdaPin = 21;
inline const int sclPin = 22;

inline const int gpsRX = 25;
inline const int gpsTX = 26;

inline const int simRX = 16;
inline const int simTX = 17;

// hardware serials
inline const int gpsHS = 2;
inline const int simHS = 1;

// 5G
inline const char* const apns[] = {
    "v-internet", // Viettel, Vietnamobile, iTel
    "m-wap",      // MobiFone
    "m3-world",   // Vinaphone, Wintel
    "internet"    // Gmobile
};
#endif