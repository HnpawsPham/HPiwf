#include <Arduino.h>
#include <SoftwareSerial.h>
#include <secrets.h>

SoftwareSerial jdy(2, 3);

void setup(){
    jdy.begin(9600);
    delay(1000);

    jdy.print("AT+NAMEibeacon-HPiwf\r\n");
    delay(200);

    jdy.print("AT+HOSTEN3\r\n");
    delay(200);

    jdy.print("AT+IBUUID" UUID "\r\n");
    delay(200);

    jdy.print("AT+MAJOR0001\r\n");
    delay(200);
    jdy.print("AT+MINOR0001\r\n");
    delay(200);

    jdy.print("AT+RST");
    delay(200);
}

void loop(){

}