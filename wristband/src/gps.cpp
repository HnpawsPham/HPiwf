#include <Arduino.h>
#include <TinyGPS++.h>
#include <mqtt-manager.h>
#include <config.h>

TinyGPSPlus gps;
HardwareSerial gpsSerial(gpsHS);

void gpsTask(void *pvParameters) {
    while(1) {
        while(gpsSerial.available() > 0)
            gps.encode(gpsSerial.read());
        vTaskDelay(200 / portTICK_PERIOD_MS);
    }
}

void initGPS(){
    gpsSerial.setRxBufferSize(2048);
    gpsSerial.begin(9600, SERIAL_8N1, gpsRX, gpsTX);

    xTaskCreatePinnedToCore(gpsTask, "GPSTask", 8192, nullptr, 1, nullptr, 0);
}

const int waitTime = 500;

void loopGPS(){
    static unsigned long prevTime = 0;

    // while(gpsSerial.available() > 0){
    //     char c = gpsSerial.read();
    //     Serial.write(c);       
    //     gps.encode(c);
    // }

    if(gps.location.isUpdated()){
        double lat = gps.location.lat();
        double lng = gps.location.lng();

        Serial.print(lat, 6);
        Serial.print(' ');
        Serial.println(lng, 6);

        // try not to spam
        if(millis() - prevTime > waitTime) {
            prevTime = millis();
            char payload[64];
            snprintf(payload, sizeof(payload), "{\"lat\":%.6f,\"lng\":%.6f}", lat, lng);
            publish("data/gps", payload);
        }
    }
}