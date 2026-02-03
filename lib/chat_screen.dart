import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  Future<void> sendMessage() async {
    String userText = controller.text;
    controller.clear();

    setState(() {
      messages.add({"role": "user", "text": userText});
    });

    var response = await http.post(
      Uri.parse('http://localhost:8000/chat'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"query": userText}),
    );

    String answer = jsonDecode(response.body)['answer'];

    setState(() {
      messages.add({"role": "bot", "text": answer});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat with PDF")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages.map((msg) {
                return ListTile(
                  title: Align(
                    alignment: msg["role"] == "user"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: msg["role"] == "user"
                            ? Colors.blue
                            : Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(msg["text"]!),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(controller: controller),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}
