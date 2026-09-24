// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import "data-controller.dart";
import 'dart:convert';
import "../config.dart";
import "notification-manager.dart";

final String MQTT_USERNAME = const String.fromEnvironment("MQTT_USERNAME");
final String MQTT_SERVER = const String.fromEnvironment("MQTT_SERVER");
final int MQTT_PORT = const int.fromEnvironment("MQTT_PORT");
final String MQTT_CLIENT_ID = const String.fromEnvironment("MQTT_CLIENT_ID");

// TOPIC WITH CORRESPODING QOS TYPE
final Map<String, MqttQos> QosMap = {
  "data/health/fall": MqttQos.exactlyOnce,
  "data/gps/lost": MqttQos.atLeastOnce,
};

class MQTTManager {
  static final MQTTManager _instance = MQTTManager._internal();
  factory MQTTManager() => _instance;
  MQTTManager._internal();

  static late MqttServerClient client;

  Future<void> _connectMQTT() async {
    client = MqttServerClient(MQTT_SERVER, MQTT_CLIENT_ID);

    client.logging(on: false);
    client.port = MQTT_PORT;
    client.autoReconnect = true;
    client.keepAlivePeriod = 20;

    client.setProtocolV311();

    final connectMess = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .authenticateAs(MQTT_USERNAME, "")
        .startClean();

    client.connectionMessage = connectMess;

    // try to connect to broker
    try {
      await client.connect();
    } catch (err) {
      print("connect to broker failed $err");
      client.disconnect();
    }

    // check connection
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print("connected to broker succesfully");
      _listen();
    } else {
      print("connected to broker failed");
      client.disconnect();
    }
  }

  void sub(String topic) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.subscribe(topic, QosMap[topic] ?? MqttQos.atMostOnce);
      print("subscribed to ${topic}");
    }
  }

  void pub(String topic, String payload) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);

      client.publishMessage(GIDPrefix(topic), MqttQos.atLeastOnce, builder.payload!);
      print("publish $payload to $topic");
    }
  }

  void _listen() {
    client.updates!.listen((mess) async {
      final topic = mess[0].topic;
      final lastMess = mess[0].payload as MqttPublishMessage;

      final String payload = MqttPublishPayload.bytesToStringAsString(lastMess.payload.message);
      if (payload.isEmpty) return;

      try {
        int dataPos = topic.indexOf("data/");
        String subTopic = dataPos != -1 ? topic.substring(dataPos) : "";

        // notify when fall
        if (subTopic == "data/health/fall") {
          DataController.instance.setFall(true);
          print("fall detected");
          LocalNoticeService.showNotification(title: "WARNING!", body: "Fall detect");
        }
        // notify when lost (geofencing upcoming)
        else if (subTopic == "data/gps/lost") {
          DataController.instance.setLost(true);
          LocalNoticeService.showNotification(title: "WARNING!", body: "User is not at home");
        }
        // notify when take off wristband
        else if (subTopic == "data/health/take-off") {
          print("wristband taken off");

          DataController.instance.setTakeOff(true);
          LocalNoticeService.showNotification(
            title: "WARNING!",
            body: "Lost vital signs! Wristband may be taken off",
          );
        }
        // get devices connection state
        else if (subTopic.startsWith("data/status"))
          DataController.instance.updateConnectionState(topic.split('/').last, payload == "online");
        // update weather info map
        else if (subTopic.startsWith("data/weather"))
          DataController.instance.updateWeather(topic.split('/').last, double.tryParse(payload));
        // update health info map
        else if (subTopic.startsWith("data/health"))
          DataController.instance.updateHealth(topic.split('/').last, double.tryParse(payload));
        // json: lat (float), lng (float)
        else if (subTopic.startsWith("data/gps")) {
          try {
            Map<String, dynamic> data = jsonDecode(payload);
            DataController.instance.updateGps(
              (data["lat"] as num?)?.toDouble(),
              (data["lng"] as num?)?.toDouble(),
            );
          } catch (err) {
            print("json parse error $err");
          }
        }
      } catch (err) {
        print("Listen error $err");
      }
    });
  }
}

Future<void> startMQTT() async {
  final mqttClient = MQTTManager();
  await mqttClient._connectMQTT();
}
