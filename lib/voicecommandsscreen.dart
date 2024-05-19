import 'package:flutter/material.dart';

class VoiceCommandsScreen extends StatelessWidget {
  const VoiceCommandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definir la lista de comandos de voz
    final List<String> commands = [
      'llanta lateral izquierda',
      'llanta lateral derecha',
      'llanta trasera izquierda',
      'llanta trasera derecha',
      'motor',
      'puerta delantera derecha',
      'puerta delantera izquierda',
      'puerta trasera derecha',
      'puerta trasera izquierda',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comandos de voz'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: commands.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text('${index + 1}.'),
            title: Text(commands[index]),
          );
        },
      ),
    );
  }
}
