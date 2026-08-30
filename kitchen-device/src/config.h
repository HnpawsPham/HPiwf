#ifndef CONFIG_H
#define CONFIG_H

const int rxPin = 2;
const int txPin = 3;

const int gasPin = 0;
const int flamePin = 1;

// threshold (default)
inline int flameThreshold = 100;
inline int gasThreshold = 400;
#endif