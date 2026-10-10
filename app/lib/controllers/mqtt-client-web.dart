import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

MqttClient createMqttClient(String server, String clientId, int port) {
  final client = MqttBrowserClient(server, clientId);
  client.port = port;
  client.websocketProtocols = const [];
  return client;
}
