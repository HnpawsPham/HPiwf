import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient createMqttClient(String server, String clientId, int port) {
  final client = MqttServerClient(server, clientId);
  client.port = port;
  return client;
}
