#ifndef REMINDER_H
#define REMINDER_H

#include <Audio.h>

extern Audio speaker;
extern String reminderList;
extern String bedtimeList;

void initSpeaker();
void initNTP();
void loopNTP();

#endif