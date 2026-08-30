#include <BluetoothSerial.h>
#include <config.h>

BluetoothSerial bluetooth;

void initBT(){
    bluetooth.begin(STATION_DEVICE_NAME, 1);
    bluetooth.setPin("1234"); //HC05 pass
}

const int duration = 5000;

void getData(const char* senderName){
    if(bluetooth.connected(0)) 
        bluetooth.disconnect();

    if(bluetooth.connect(senderName)){
        Serial.print("Collecting data from ");
        Serial.println(senderName);

        unsigned long startTime = millis();
        while (millis() - startTime <= duration){
            while (bluetooth.available()){
                char c = bluetooth.read();
                Serial.write(c);
            }
        }
    }
    else{
        Serial.print("Couldn't connect to ");
        Serial.println(senderName);
    }
}

String curReceiver = "";

void sendData(const char* receiverName, const char* val){
    if(curReceiver != receiverName){
        if(bluetooth.connected(0))
            bluetooth.disconnect();
    }

    if(bluetooth.connect(receiverName)){
        curReceiver = receiverName;

        Serial.print("Sending data to ");
        Serial.println(receiverName);

        bluetooth.println(val);
    }
    else{
        Serial.print("Couldn't connect to ");
        Serial.println(receiverName);
    }
}

bool changeDevice = 0;

void loopBT(){
    static unsigned long prevTime = 0;
    
    if(millis() - prevTime > duration){
        prevTime = millis();

        if(changeDevice)
            getData(DOOR_DEVICE_NAME);
        else getData(KITCHEN_DEVICE_NAME);
        
        changeDevice = !changeDevice;
    }
}