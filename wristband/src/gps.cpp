#include <Arduino.h>
#include <TinyGPS++.h>
#include <mqtt-manager.h>
#include <config.h>
#include <helper.h>

TinyGPSPlus gps;
HardwareSerial gpsSerial(gpsHS);

void initGPS(){
    gpsSerial.begin(9600, SERIAL_8N1, gpsRX, gpsTX);
}

const int waitTime = 500;

void loopGPS(){
    static unsigned long prevTime = 0;

    // while(gpsSerial.available() > 0){
    //     char c = gpsSerial.read();
    //     Serial.write(c);       
    //     gps.encode(c);
    // }

    while(gpsSerial.available() > 0)
        if(gps.encode(gpsSerial.read())){
            if(gps.location.isValid()){
                double lat = gps.location.lat();
                double lng = gps.location.lng();

                Serial.print(lat, 6);
                Serial.print(' ');
                Serial.println(lng, 6);

                // try not to spam
                if(millis() - prevTime > waitTime){
                    prevTime = millis();
                    publish(GIDPrefix("data/gps/lat"), String(lat, 6).c_str());
                    publish(GIDPrefix("data/gps/lng"), String(lng, 6).c_str());
                }
            }
        }
}