import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Fridge Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FridgeMonitor(),
    );
  }
}

class FridgeMonitor extends StatefulWidget {
  @override
  _FridgeMonitorState createState() => _FridgeMonitorState();
}

class _FridgeMonitorState extends State<FridgeMonitor> {
  final String broker = 'cd8839ea5ec5423da3aaa6691e5183a5.s1.eu.hivemq.cloud';
  final int port = 8883;
  final String username = 'hivemq.webclient.1734636778463';
  final String password = 'EU<pO3F7x?S%wLk4#5ib';
  final String statusTopic = 'esp32/refrigerator';

  MqttServerClient? client;
  String temperature = 'N/A';
  String humidity = 'N/A';
  String doorStatus = 'N/A';
  String user = 'N/A';

  @override
  void initState() {
    super.initState();
    _connectToBroker();
  }

  Future<void> _connectToBroker() async {
    client = MqttServerClient(broker, 'flutter_client');
    client!.port = port;
    client!.secure = true;
    client!.logging(on: true);
    client!.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .authenticateAs(username, password);

    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
      client!.subscribe(statusTopic, MqttQos.atMostOnce);
      client!.updates!.listen(_onMessageReceived);
      print('Connected to the broker');
    } catch (e) {
      print('Connection failed: $e');
      client!.disconnect();
    }
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> messages) {
    final recMessage = messages.first.payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

    try {
      final data = jsonDecode(payload);
      setState(() {
        temperature = data['temperatura'].toString();
        humidity = data['umidade'].toString();
        doorStatus = data['estado_porta'];
        user = data['usuario'];
      });
    } catch (e) {
      print('Error processing message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Fridge Monitor 1'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(
              title: 'Temperature',
              value: '$temperature °C',
              icon: Icons.thermostat,
              color: Colors.redAccent,
            ),
            _buildInfoCard(
              title: 'Humidity',
              value: '$humidity %',
              icon: Icons.water_drop,
              color: Colors.blueAccent,
            ),
            _buildInfoCard(
              title: 'Door Status',
              value: doorStatus,
              icon: Icons.door_front_door,
              color: Colors.orangeAccent,
            ),
            _buildInfoCard(
              title: 'User',
              value: user,
              icon: Icons.person,
              color: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 40, color: color),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
