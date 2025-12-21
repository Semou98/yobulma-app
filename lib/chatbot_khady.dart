import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class KhadyChatWrapper extends StatefulWidget {
  final Widget child;
  const KhadyChatWrapper({super.key, required this.child});

  @override
  State<KhadyChatWrapper> createState() => _KhadyChatWrapperState();
}

class _KhadyChatWrapperState extends State<KhadyChatWrapper> {
  bool _isChatOpen = false;
  bool _isLoading = false;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final String _apiUrl = "https://chatyobulma.onrender.com/chat";

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _messages.add({"sender": "khady", "text": data['response']});
        });
      }
    } catch (e) {
      setState(
        () => _messages.add({
          "sender": "khady",
          "text": "Désolée, j'ai un petit souci technique.",
        }),
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    final String? currentRoute = route?.settings.name;
    final List<String> excludedRoutes = ['/welcome', '/login', '/register'];

    if (excludedRoutes.contains(currentRoute)) {
      return widget.child;
    }

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          if (_isChatOpen) _buildMiniChat(),
          _buildFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildMiniChat() {
    return Positioned(
      left: 15,
      bottom: 85,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 280,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Column(
            children: [
              // Header personnalisé pour Khady
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.face_3, color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Khady",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "En ligne",
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isChatOpen = false),
                    ),
                  ],
                ),
              ),
              // Zone des messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.isEmpty ? 1 : _messages.length,
                  itemBuilder: (context, index) {
                    if (_messages.isEmpty) {
                      return Center(
                        child: Text(
                          "Bonjour ! Je suis Khady. Comment puis-je vous aider ?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                    final m = _messages[index];
                    bool isUser = m["sender"] == "user";
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: 200),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.orange.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: Radius.circular(isUser ? 15 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 15),
                          ),
                        ),
                        child: MarkdownBody(
                          data: m["text"]!,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isLoading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: Colors.orange,
                ),
              // Input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Écrivez à Khady...",
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 4),
                    CircleAvatar(
                      backgroundColor: Colors.orange,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => _sendMessage(_controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Positioned(
      left: 15,
      bottom: 20,
      child: GestureDetector(
        onTap: () => setState(() => _isChatOpen = !_isChatOpen),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!_isChatOpen)
                const Icon(Icons.face_3, color: Colors.white, size: 20)
              else
                const Icon(Icons.close, color: Colors.white, size: 20),
              // Petit badge pour indiquer que c'est une IA
              if (!_isChatOpen)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
