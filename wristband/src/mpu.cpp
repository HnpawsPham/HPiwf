#include <Arduino.h>
#include <Adafruit_MPU6050.h>
#include <data-transfer.h>
#include <config.h>
#include <fall-detection-ML.h>

using namespace std;
Adafruit_MPU6050 mpu;
Eloquent::ML::Port::RandomForest model;

const int WINSZ = 20;
const int STEP = 5;
const int FEATS_CNT = 43;

float winAx[WINSZ], winAy[WINSZ], winAz[WINSZ];
float winGx[WINSZ], winGy[WINSZ], winGz[WINSZ];

void initMPU(){
    Wire.begin(sdaPin, sclPin);
    if(!mpu.begin()){
        Serial.println("MPU error");
        return;
    }
    Serial.println("MPU found");
}

void calc(float *a, int len, float &mean, float &std, float &minn, float &maxx, float &p2p){
    float sum = 0.0f;
    minn = a[0];
    maxx = a[0];

    for(int i = 0; i < len; i++){
        sum += a[i];
        if(a[i] < minn) minn = a[i];
        if(a[i] > maxx) maxx = a[i];
    }

    mean = sum / len;
    p2p = maxx - minn;
    float sum_sq_diff = 0.0f;
    for(int i = 0; i < len; i++)
        sum_sq_diff += (a[i] - mean) * (a[i] - mean);

    std = sqrt(sum_sq_diff / len);
}

void extractFeatures(float *feat){
    int fid = 0;
    float mean, std, minn, maxx, p2p;

    calc(winAx, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = mean;
    feat[fid++] = std;
    feat[fid++] = minn;
    feat[fid++] = maxx;
    feat[fid++] = p2p;

    calc(winAy, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = mean;
    feat[fid++] = std;
    feat[fid++] = minn;
    feat[fid++] = maxx;
    feat[fid++] = p2p;

    calc(winAz, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = mean;
    feat[fid++] = std;
    feat[fid++] = minn;
    feat[fid++] = maxx;
    feat[fid++] = p2p;

    calc(winGx, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = mean;
    feat[fid++] = std;
    feat[fid++] = minn;
    feat[fid++] = maxx;
    feat[fid++] = p2p;

    calc(winGy, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = mean;
    feat[fid++] = std;
    feat[fid++] = minn;
    feat[fid++] = maxx;
    feat[fid++] = p2p;

    calc(winGz, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = mean;
    feat[fid++] = std;
    feat[fid++] = minn;
    feat[fid++] = maxx;
    feat[fid++] = p2p;

    // a_mag
    float a_mag[WINSZ];
    for(int i = 0; i < WINSZ; i++)
        a_mag[i] = sqrt(winAx[i] * winAx[i] + winAy[i] * winAy[i] + winAz[i] * winAz[i]);

    calc(a_mag, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = mean; // a_mag_mean
    feat[fid++] = std;  // a_mag_std
    feat[fid++] = maxx; // a_mag_max
    feat[fid++] = minn; // a_mag_min
    feat[fid++] = p2p;  // a_mag_p2p

    float a_energy_sum = 0.0f;
    for(int i = 0; i < WINSZ; i++)
        a_energy_sum += a_mag[i] * a_mag[i];

    feat[fid++] = a_energy_sum / WINSZ; // a_mag_energy

    // a jerk
    float a_jerk[WINSZ - 1];
    float jerk_max = 0.0f;
    float jerk_sum = 0.0f;
    for(int i = 0; i < WINSZ - 1; i++){
        a_jerk[i] = a_mag[i + 1] - a_mag[i];
        float abs_jerk = abs(a_jerk[i]);

        if(abs_jerk > jerk_max)
            jerk_max = abs_jerk;

        jerk_sum += a_jerk[i];
    }

    float jerk_mean = jerk_sum / (WINSZ - 1);
    float jerk_std_sum = 0.0f;
    for(int i = 0; i < WINSZ - 1; i++)
        jerk_std_sum += (a_jerk[i] - jerk_mean) * (a_jerk[i] - jerk_mean);

    float jerk_std = sqrt(jerk_std_sum / (WINSZ - 1));
    feat[fid++] = jerk_max; // a_jerk_max
    feat[fid++] = jerk_std; // a_jerk_std

    // calc g mag
    float g_mag[WINSZ];
    for(int i = 0; i < WINSZ; i++)
        g_mag[i] = sqrt(winGx[i] * winGx[i] + winGy[i] * winGy[i] + winGz[i] * winGz[i]);

    calc(g_mag, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = mean; // g_mag_mean
    feat[fid++] = std;  // g_mag_std
    feat[fid++] = maxx; // g_mag_max
    feat[fid++] = p2p;  // g_mag_p2p

    float g_energy_sum = 0.0f;
    for(int i = 0; i < WINSZ; i++)
        g_energy_sum += g_mag[i] * g_mag[i];

    feat[fid++] = g_energy_sum / WINSZ; // g_mag_energy
}

void shiftWin(){
    for(int i = 0; i < WINSZ - STEP; i++){
        winAx[i] = winAx[i + STEP];
        winAy[i] = winAy[i + STEP];
        winAz[i] = winAz[i + STEP];
        winGx[i] = winGx[i + STEP];
        winGy[i] = winGy[i + STEP];
        winGz[i] = winGz[i + STEP];
    }
}

int buffId = 0;

void loopMPU(){
    static unsigned long prevTime = 0;

    if(millis() - prevTime > 100){
        prevTime = millis();

        sensors_event_t a, g, temp;
        mpu.getEvent(&a, &g, &temp);

        winAx[buffId] = a.acceleration.x;
        winAy[buffId] = a.acceleration.y;
        winAz[buffId] = a.acceleration.z;
        winGx[buffId] = g.gyro.x;
        winGy[buffId] = g.gyro.y;
        winGz[buffId] = g.gyro.z;
        buffId++;

        if(buffId >= WINSZ){
            String data = String(millis()) + ',' + String(a.acceleration.x) + ',' + String(a.acceleration.y) + ',';
            data = data + String(a.acceleration.z) + ',' + String(g.gyro.x) + ',' + String(g.gyro.y) + ',' + String(g.gyro.z);

            // Serial.println(data);

            // handle ML inputs
            float feat[FEATS_CNT];
            extractFeatures(feat);

            int ypred = model.predict(feat);
            // Serial.print("pred: ");
            // Serial.println(ypred);

            if(ypred == 0)
                Serial.println(" " + String(millis()));

            shiftWin();
            buffId = WINSZ - STEP;
        }
    }
}