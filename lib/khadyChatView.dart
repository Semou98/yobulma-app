import 'dart:convert';
import 'dart:io';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KhadyAssistantWrapper extends StatefulWidget {
  const KhadyAssistantWrapper({super.key});

  @override
  State<KhadyAssistantWrapper> createState() => _KhadyAssistantWrapperState();
}

class _KhadyAssistantWrapperState extends State<KhadyAssistantWrapper> {
  // Votre code HTML original légèrement épuré pour le mobile
  final String _htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <style>
        body { margin: 0; padding: 0; font-family: sans-serif; background: #f3f4f6; }
        #chat-window { height: calc(100vh - 130px); overflow-y: auto; padding: 15px; display: flex; flex-direction: column; gap: 12px; }
        .bot-msg { align-self: flex-start; background: white; padding: 12px; border-radius: 15px 15px 15px 0; max-width: 85%; border: 1px solid #e5e7eb; font-size: 14px; }
        .user-msg { align-self: flex-end; background: #ea580c; color: white; padding: 12px; border-radius: 15px 15px 0 15px; max-width: 85%; font-size: 14px; }
        #loader { display: none; color: #666; font-style: italic; font-size: 12px; margin-left: 10px; }
    </style>
</head>
<body>
    <div class="bg-orange-600 p-4 text-white font-bold flex justify-between items-center sticky top-0">
        <span>Khady - Assistant YOBULMA</span>
    </div>
    
    <div id="chat-window">
        <div class="bot-msg"><b>Salam !</b> Je suis Khady. Comment puis-je vous aider aujourd'hui ?</div>
    </div>
    
    <div id="loader">Khady réfléchit...</div>

    <div class="fixed bottom-0 w-full p-3 bg-white border-t flex gap-2">
        <input type="text" id="user-input" class="flex-1 border rounded-full px-4 py-2 outline-none focus:border-orange-500" placeholder="Écrivez ici...">
        <button onclick="sendMessage()" class="bg-orange-600 text-white px-5 py-2 rounded-full font-bold">OK</button>
    </div>

    <script>
        const API_URL = "https://chatyobulma.onrender.com/chat";
        const chatWindow = document.getElementById('chat-window');
        const loader = document.getElementById('loader');

        async function sendMessage() {
            const input = document.getElementById('user-input');
            const message = input.value.trim();
            if (!message) return;

            chatWindow.innerHTML += `<div class="user-msg">\${message}</div>`;
            input.value = '';
            chatWindow.scrollTop = chatWindow.scrollHeight;
            
            loader.style.display = 'block';

            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: message })
                });
                const data = await response.json();
                loader.style.display = 'none';
                chatWindow.innerHTML += `<div class="bot-msg">\${marked.parse(data.response)}</div>`;
            } catch (error) {
                loader.style.display = 'none';
                chatWindow.innerHTML += `<div class="text-red-500 text-xs">Erreur de connexion...</div>`;
            }
            chatWindow.scrollTop = chatWindow.scrollHeight;
        }
    </script>
</body>
</html>
''';

  void _openChatPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(Colors.white)
              ..loadHtmlString(_htmlContent),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // On n'affiche pas Khady sur le Web dans cet exemple
    if (kIsWeb) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 10),
      child: GestureDetector(
        onTap: _openChatPanel,
        child: SizedBox(
          width: 80,
          height: 80,
          // Ici vous pouvez mettre votre composant Lottie si vous avez le package lottie
          // En attendant, j'utilise une icône stylisée
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 8, height: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
