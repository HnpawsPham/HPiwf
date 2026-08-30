#include <Arduino.h>
#include <DHT.h>
#include <bluetooth-manager.h>
#include <mqtt-manager.h>
#include <config.h>
#include <Adafruit_BMP280.h>

DHT dht(dhtPin, DHT11);
Adafruit_BMP280 bmp;

const int bmpSDA = 21;
const int bmpSCL = 22;

void initSensors(){
  dht.begin();
  
  Wire.begin(bmpSDA, bmpSCL);
  if (!bmp.begin(0x76) && !bmp.begin(0x77)){
    Serial.println("BMP error");
    return;
  }
  
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

  if (millis() - prevTime >= duration){
    prevTime = millis();

    float humid = dht.readHumidity();
    float temp = dht.readTemperature();

    Serial.print("Humidity: ");
    Serial.println(humid);
    publish("data/weather/humid", humid);

    Serial.print("Temperature: ");
    Serial.println(temp);
    publish("data/weather/temp", temp);

    int airPpm = analogRead(airQualityPin);
    Serial.print("Air quality ppm: ");
    Serial.println(airPpm);
    publish("data/weather/air-ppm", airPpm);

    int rainVal = analogRead(rainPin);
    Serial.print("Rain val: ");
    Serial.println(rainVal);
    publish("data/weather/rain-val", rainVal);

    float airPressureVal = bmp.readPressure();
    Serial.print("Air pressure: ");
    Serial.println(airPressureVal);
    publish("data/weather/air-pressure", airPressureVal);

    if (maxAmp != -1){
      Serial.print("Noise delta: ");
      Serial.println(maxAmp - minAmp);
      publish("data/weather/noise-delta", maxAmp - minAmp);
      
      minAmp = 100005;
      maxAmp = -1;
    }
  }
}