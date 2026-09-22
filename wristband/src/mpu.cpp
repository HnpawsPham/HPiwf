#include <Arduino.h>
#include <Adafruit_MPU6050.h>
#include <mqtt-manager.h>
#include <config.h>
#include <fall-detection-ML.h>
#include <helper.h>

using namespace std;
Adafruit_MPU6050 mpu;

const int WINSZ = 20;
const int STEP = 5;
const int FEATS_CNT = 43;

float winAx[WINSZ], winAy[WINSZ], winAz[WINSZ];
float winGx[WINSZ], winGy[WINSZ], winGz[WINSZ];

void initMPU() {
    Wire.begin(sdaPin, sclPin);
    if(!mpu.begin()) {
        Serial.println("MPU error");
        return;
    }
    Serial.println("MPU found");
}

void calc(float *a, int len, float &mean, float &std, float &minn, float &maxx, float &p2p) {
    float sum = 0.0f;
    minn = a[0];
    maxx = a[0];

    for (int i = 0; i < len; i++) {
        sum += a[i];
        if (a[i] < minn) minn = a[i];
        if (a[i] > maxx) maxx = a[i];
    }

    mean = sum / len;
    p2p = maxx - minn;
    float sum_sq_diff = 0.0f;
    for (int i = 0; i < len; i++)
        sum_sq_diff += (a[i] - mean) * (a[i] - mean);

    std = sqrt(sum_sq_diff / len);
}

void extractFeatures(float *feat) {
    int fid = 0;
    float mean, std, minn, maxx, p2p;

    calc(winAx, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = (float)mean;
    feat[fid++] = (float)std;
    feat[fid++] = (float)minn;
    feat[fid++] = (float)maxx;
    feat[fid++] = (float)p2p;

    calc(winAy, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = (float)mean;
    feat[fid++] = (float)std;
    feat[fid++] = (float)minn;
    feat[fid++] = (float)maxx;
    feat[fid++] = (float)p2p;

    calc(winAz, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = (float)mean;
    feat[fid++] = (float)std;
    feat[fid++] = (float)minn;
    feat[fid++] = (float)maxx;
    feat[fid++] = (float)p2p;

    calc(winGx, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = (float)mean;
    feat[fid++] = (float)std;
    feat[fid++] = (float)minn;
    feat[fid++] = (float)maxx;
    feat[fid++] = (float)p2p;

    calc(winGy, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = (float)mean;
    feat[fid++] = (float)std;
    feat[fid++] = (float)minn;
    feat[fid++] = (float)maxx;
    feat[fid++] = (float)p2p;

    calc(winGz, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = (float)mean;
    feat[fid++] = (float)std;
    feat[fid++] = (float)minn;
    feat[fid++] = (float)maxx;
    feat[fid++] = (float)p2p;

    float a_mag[WINSZ];
    for (int i = 0; i < WINSZ; i++)
        a_mag[i] = sqrt(winAx[i] * winAx[i] + winAy[i] * winAy[i] + winAz[i] * winAz[i]);

    calc(a_mag, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = (float)mean;
    feat[fid++] = (float)std;
    feat[fid++] = (float)maxx;
    feat[fid++] = (float)minn;
    feat[fid++] = (float)p2p;

    float a_energy_sum = 0.0f;
    for (int i = 0; i < WINSZ; i++)
        a_energy_sum += a_mag[i] * a_mag[i];

    feat[fid++] = (float)(a_energy_sum / WINSZ);

    float a_jerk[WINSZ - 1];
    float jerk_max = 0.0f;
    float jerk_sum = 0.0f;
    for (int i = 0; i < WINSZ - 1; i++) {
        a_jerk[i] = a_mag[i + 1] - a_mag[i];

        if (abs(a_jerk[i]) > jerk_max)
            jerk_max = abs(a_jerk[i]);

        jerk_sum += a_jerk[i];
    }

    float jerk_std_sum = 0.0f;
    for (int i = 0; i < WINSZ - 1; i++)
        jerk_std_sum += (a_jerk[i] - (jerk_sum / (WINSZ - 1))) * (a_jerk[i] - (jerk_sum / (WINSZ - 1)));

    feat[fid++] = (float)jerk_max;
    feat[fid++] = (float)sqrt(jerk_std_sum / (WINSZ - 1));

    float g_mag[WINSZ];
    for (int i = 0; i < WINSZ; i++)
        g_mag[i] = sqrt(winGx[i] * winGx[i] + winGy[i] * winGy[i] + winGz[i] * winGz[i]);

    calc(g_mag, WINSZ, mean, std, minn, maxx, p2p);
    feat[fid++] = (float)mean;
    feat[fid++] = (float)std;
    feat[fid++] = (float)maxx;
    feat[fid++] = (float)p2p;

    float g_energy_sum = 0.0f;
    for (int i = 0; i < WINSZ; i++)
        g_energy_sum += g_mag[i] * g_mag[i];

    feat[fid++] = (float)(g_energy_sum / WINSZ);
}

void shiftWin() {
    for (int i = 0; i < WINSZ - STEP; i++) {
        winAx[i] = winAx[i + STEP];
        winAy[i] = winAy[i + STEP];
        winAz[i] = winAz[i + STEP];
        winGx[i] = winGx[i + STEP];
        winGy[i] = winGy[i + STEP];
        winGz[i] = winGz[i + STEP];
    }
}

int buffId = 0;
int cntFallVote = 0;
const int FALL_VOTE_THRESHOLD = 3;

void loopMPU() {
    static unsigned long prevTime = 0;

    if (millis() - prevTime >= 100) {
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

        if (buffId >= WINSZ) {
            float feat[FEATS_CNT];
            extractFeatures(feat);

            float proba = FallDetectionModel::predict_proba(feat);
            int ypred = FallDetectionModel::predict(feat, 0.5f);

            // Serial.println(ypred);

            if(ypred) {
                cntFallVote++;
                if (cntFallVote >= FALL_VOTE_THRESHOLD) {
                    publish("data/fall", String(millis()).c_str());
                    cntFallVote = 0;
                }
            } else cntFallVote = 0;

            shiftWin();
            buffId = WINSZ - STEP;
        }
    }
}