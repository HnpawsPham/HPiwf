#include <Arduino.h>
#include <config.h>
#include <Audio.h>

Audio speaker;

void initSpeaker(){
    speaker.setPinout(blckPin, lrcPin, dinPin);
    speaker.setVolume(21);
    speaker.setTone(4, 0, 4);
}