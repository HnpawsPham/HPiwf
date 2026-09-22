#include <BluetoothSerial.h>
#include <HardwareSerial.h>
#include <config.h>
#include <mqtt-manager.h>

BluetoothSerial bluetooth;
HardwareSerial hc05(2); //additional bluetooth module

uint8_t doorDeviceMac[6] = {0x00, 0x23, 0x10, 0xA0, 0x2A, 0x47};
unsigned long lastConnectDoor = 0;
bool doorConnected = 0;
const unsigned long RECONNECT_DOOR_WAITTIME = 5000; 

void connectDoor(){
    if(!doorConnected){
        doorConnected = bluetooth.connect(doorDeviceMac, 1, ESP_SPP_SEC_AUTHENTICATE);
        if(doorConnected){
            publish("data/status/door-device", "online");
            Serial.println("connected to door");
        }
        else Serial.println("connect to door failed");
    }
}

void connectKitchen(){
    hc05.begin(9600, SERIAL_8N1, btRX, btTX);
    if(digitalRead(statePin)){
        publish("data/status/kitchen-device", "online");
        Serial.println("connected to kitchen");
    }
    else Serial.println("connect to kitchen failed");
}
    

void initBT(){
    bluetooth.begin(STATION_DEVICE_NAME, 1);
    bluetooth.setPin("1234"); //child pass
    delay(500); 

    connectDoor();
    connectKitchen();
}

bool sendData(const char* receiverName, const char* val){
    if(strcmp(receiverName, DOOR_DEVICE_NAME) == 0) {
        if(!bluetooth.connected()){
            Serial.println("door BT not connected");
            publish("data/status/door-device", "offline");
            doorConnected = 0;
            return 0;
        }
  
        Serial.print("Sending data to ");
        Serial.println(receiverName);
        bluetooth.println(val);
        return 1;
    }
    else if(strcmp(receiverName, KITCHEN_DEVICE_NAME) == 0){      
        Serial.print("Sending data to ");
        Serial.println(receiverName);
        hc05.println(val);
    }
    return 1;
}

void loopBT(){
    if(!bluetooth.connected() && millis() - lastConnectDoor > RECONNECT_DOOR_WAITTIME){
        lastConnectDoor = millis();
        connectDoor();
    }

    if(bluetooth.available()){
        String data = bluetooth.readStringUntil('\n');
        data.trim();

        if(data.length()){
            Serial.println(data);
            if(data.indexOf("vibration") != -1)
                publish("data/notification/satellite", "vibration");
            
            if(data.indexOf("obstacle") != -1)
                publish("data/notification/satellite", "obstacle");
        }
    }

    while(Serial.available())
        hc05.write(Serial.read());

    if(!digitalRead(statePin)){
        publish("data/status/kitchen-device", "online");
        return;
    }

    if(hc05.available()){
        String data = hc05.readStringUntil('\n');
        data.trim();

        if(data.length()){
            Serial.println(data);
            if(data.indexOf("flame") != -1)
                publish("data/notification/satellite", "flame");
            
            if(data.indexOf("gas") != -1)
                publish("data/notification/satellite", "gas");
        }
    }
}