import 'dart:convert';
import 'dart:js_interop';

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
  String user = 'N/A'; // Adicionado usuário

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
    client!.onDisconnected = _onDisconnected;
    client!.onConnected = _onConnected;
    client!.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .authenticateAs(username, password);

    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
    } catch (e) {
      print('Connection failed: $e');
      client!.disconnect();
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.subscribe(statusTopic, MqttQos.atMostOnce);
      client!.updates!.listen(_onMessageReceived);
      print('Connected to the broker');
    } else {
      print('Connection failed: ${client!.connectionStatus}');
    }
  }

  void _onDisconnected() {
    print('Disconnected from the broker');
  }

  void _onConnected() {
    print('Connected to the broker!!!!!!!!!!!!!!!!!!!!');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> messages) {
  final recMessage = messages.first.payload as MqttPublishMessage;
  final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

  print('Mensagem recebida no tópico ${messages.first.topic}: $payload');

  // Processa apenas mensagens do tópico 'esp32/refrigerator'
  if (messages.first.topic == 'esp32/refrigerator') {
    try {
      // Decodifica o payload JSON
      final data = jsonDecode(payload);
      print(data.jsify());
      setState(() {
        // Atualiza os valores com base no JSON recebido
        temperature = data['temperatura'].toString();
        humidity = data['umidade'].toString();
        doorStatus = data['estado_porta'];
        user = data['usuario'];

        // Debug no console para verificar os valores recebidos
        print('Temperatura: $temperature°C');
        print('Umidade: $humidity%');
        print('Estado da porta: $doorStatus');
        print('Usuário: $user');
      });
    } catch (e) {
      // Caso haja erro ao decodificar o JSON, exibe no console
      print('Erro ao processar a mensagem JSON: $e');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Fridge Monitor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Temperature: $temperature °C', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Humidity: $humidity %', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Door Status: $doorStatus', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('User: $user', style: TextStyle(fontSize: 20)), // Exibe o usuário
          ],
        ),
      ),
    );
  }
}