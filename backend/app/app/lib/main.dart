import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JARVIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),
      home: const JarvisHome(),
    );
  }
}

class JarvisHome extends StatefulWidget {
  const JarvisHome({super.key});

  @override
  State<JarvisHome> createState() => _JarvisHomeState();
}

class _JarvisHomeState extends State<JarvisHome> {
  final controller = TextEditingController();

  String response = 'Ready.';
  bool loading = false;

  // Change this when your backend is deployed.
  final String backend = 'http://10.0.2.2:8000';

  Future<void> executeCommand() async {
    final command = controller.text.trim();

    if (command.isEmpty) return;

    setState(() {
      loading = true;
      response = 'Thinking...';
    });

    try {
      final result = await http.post(
        Uri.parse('$backend/command'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'command': command,
        }),
      );

      if (result.statusCode != 200) {
        throw Exception('Backend error ${result.statusCode}');
      }

      final data = jsonDecode(result.body);
      final actions = data['actions'] as List;

      await executeActions(actions);
    } catch (e) {
      setState(() {
        response = 'Error: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> executeActions(List actions) async {
    for (final action in actions) {
      final type = action['type'];

      if (type == 'open_app') {
        final app = action['app'];

        if (app == 'instagram') {
          await openInstagram();
        }
      } else if (type == 'send_message') {
        final person = action['person'];
        final message = action['message'];

        setState(() {
          response =
              'Message requested: "$message" → $person\n'
              'Instagram automation is platform-specific.';
        });
      } else {
        setState(() {
          response = 'I do not understand that command yet.';
        });
      }
    }
  }

  Future<void> openInstagram() async {
    final urls = [
      Uri.parse('instagram://app'),
      Uri.parse('https://www.instagram.com/'),
    ];

    for (final uri in urls) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          setState(() {
            response = 'Opening Instagram...';
          });

          return;
        }
      } catch (_) {}
    }

    setState(() {
      response = 'Could not open Instagram.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'JARVIS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            const Icon(
              Icons.memory,
              size: 100,
              color: Colors.cyan,
            ),

            const SizedBox(height: 24),

            Text(
              response,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Say something to JARVIS...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: loading ? null : executeCommand,
                ),
              ),
              onSubmitted: (_) => executeCommand(),
            ),

            const SizedBox(height: 20),

            if (loading)
              const CircularProgressIndicator(),

            const Spacer(),

            const Text(
              'Example: open Instagram and message BeeshAl hi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
