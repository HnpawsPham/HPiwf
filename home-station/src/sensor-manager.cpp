#include <Arduino.h>
#include <DHT.h>
#include <bluetooth-manager.h>
#include <mqtt-manager.h>
#include <config.h>
#include <Adafruit_BMP280.h>

DHT dht(dhtPin, DHT11);
Adafruit_BMP280 bmp;

void initSensors(){
    dht.begin();
    
    Wire.begin(bmpSDA, bmpSCL);
    delay(500);
    
    if(!bmp.begin(0x76))
        Serial.println("BMP error");

    bmp.setSampling(Adafruit_BMP280::MODE_NORMAL,
                Adafruit_BMP280::SAMPLING_X2,
                Adafruit_BMP280::SAMPLING_X16,
                Adafruit_BMP280::FILTER_X16,
                Adafruit_BMP280::STANDBY_MS_500);

    pinMode(rainPin, INPUT);
    pinMode(airQualityPin, INPUT);
    pinMode(noisePin, INPUT);
}

unsigned int duration = 2000;
int minAmp = 100005, maxAmp = -1;

void loopSensors(){
    static unsigned long prevTime = 0;

    int noiseVal = analogRead(noisePin);
    minAmp = min(minAmp, noiseVal);
    maxAmp = max(maxAmp, noiseVal);

    if(millis() - prevTime >= duration){
        prevTime = millis();

        float humid = dht.readHumidity();
        float temp = dht.readTemperature();

        publish("data/weather/humid", humid);

        // Serial.print("Temperature: ");
        // Serial.println(temp);
        publish("data/weather/temp", temp);

        int airPpm = analogRead(airQualityPin) + 300;
        // Serial.print("Air quality ppm: ");
        // Serial.println(airPpm);
        publish("data/weather/air-ppm", airPpm);

        int rainVal = analogRead(rainPin);
        // Serial.print("Rain val: ");
        // Serial.println(rainVal);
        publish("data/weather/rain-val", rainVal);

        float airPressureVal = bmp.readPressure();
        if(isnan(airPressureVal)) airPressureVal = 1013.25;
        // Serial.print("Air pressure: ");
        // Serial.println(airPressureVal);
        publish("data/weather/air-pressure", airPressureVal);

        if(maxAmp != -1){
            // Serial.print("Noise delta: ");
            // Serial.println(maxAmp - minAmp);
            publish("data/weather/noise-delta", maxAmp - minAmp);
            
            minAmp = noiseVal;
            maxAmp = noiseVal;
        }
    }
}