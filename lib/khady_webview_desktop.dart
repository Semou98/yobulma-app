import 'package:flutter/material.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';

import 'package:flutter/material.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'dart:convert';

class KhadyWebViewDesktop extends StatelessWidget {
  const KhadyWebViewDesktop({super.key});

  Future<void> _openChatbot() async {
    if (await WebviewWindow.isWebviewAvailable()) {
      final webview = await WebviewWindow.create(
        configuration: CreateConfiguration(
          title: 'Khady - Assistant YOBULMA',
          // width: 450,
          // height: 700,
        ),
      );

      // Utiliser dataUrl au lieu de launch
      final htmlContent = _getHtmlContent();
      final dataUrl =
          'data:text/html;base64,${base64Encode(utf8.encode(htmlContent))}';
      webview.launch(dataUrl);
    }
  }

  String _getHtmlContent() {
    return '''
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khady Chatbot - YOBULMA</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/@lottiefiles/dotlottie-wc@0.8.11/dist/dotlottie-wc.js" type="module"></script>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    
    <style>
        body { margin: 0; padding: 0; background: white; }
        .bot-message strong { font-weight: 800; color: #1a1a1a; }
        .bot-message p { margin-bottom: 8px; }
        .bot-message ul { list-style-type: disc; margin-left: 20px; margin-bottom: 8px; }
        #chat-window::-webkit-scrollbar { width: 5px; }
        #chat-window::-webkit-scrollbar-track { background: #f1f1f1; }
        #chat-window::-webkit-scrollbar-thumb { background: #ea580c; border-radius: 10px; }
    </style>
</head>
<body>
    <div class="flex flex-col h-screen">
        <div class="bg-orange-600 p-4 text-white font-bold flex items-center gap-2">
            <div class="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
            <span>Khady - Assistant YOBULMA</span>
        </div>
        
        <div id="chat-window" class="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50 text-sm flex flex-col">
            <div class="bg-orange-100 p-3 rounded-xl rounded-tl-none text-gray-800 self-start max-w-[90%] border border-orange-200 shadow-sm">
                Salam ! Je suis <b>Khady</b>. Comment puis-je vous aider aujourd'hui ?
            </div>
        </div>

        <div class="p-3 border-t bg-white flex gap-2">
            <input type="text" id="user-input" autocomplete="off" placeholder="Écrivez votre message..." class="flex-1 border rounded-full px-4 py-2 focus:outline-none focus:border-orange-500 text-sm">
            <button onclick="sendMessage()" class="bg-orange-600 text-white px-5 py-2 rounded-full hover:bg-orange-700 transition font-medium">OK</button>
        </div>
    </div>

    <script>
        const API_URL = "https://chatyobulma.onrender.com/chat";

        async function sendMessage() {
            const input = document.getElementById('user-input');
            const chatWindow = document.getElementById('chat-window');
            const message = input.value.trim();

            if (!message) return;

            chatWindow.innerHTML += \`
                <div class="bg-orange-600 text-white p-3 rounded-xl rounded-tr-none self-end ml-auto max-w-[85%] shadow-sm">
                    \${message}
                </div>\`;
            
            input.value = '';
            chatWindow.scrollTop = chatWindow.scrollHeight;

            const loaderId = "loader-" + Date.now();
            chatWindow.innerHTML += \`
                <div id="\${loaderId}" class="bg-gray-200 text-gray-500 p-3 rounded-xl rounded-tl-none self-start mr-auto shadow-sm italic flex items-center gap-2">
                    Khady réfléchit...
                </div>\`;
            chatWindow.scrollTop = chatWindow.scrollHeight;

            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: message })
                });

                if (!response.ok) throw new Error("Erreur réseau");

                const data = await response.json();
                
                document.getElementById(loaderId).remove();
                
                const formattedResponse = marked.parse(data.response);
                
                chatWindow.innerHTML += \`
                    <div class="bg-white border border-gray-200 text-gray-800 p-3 rounded-xl rounded-tl-none self-start mr-auto max-w-[90%] shadow-sm bot-message">
                        \${formattedResponse}
                    </div>\`;

            } catch (error) {
                console.error("Erreur:", error);
                if(document.getElementById(loaderId)) document.getElementById(loaderId).remove();
                chatWindow.innerHTML += \`
                    <div class="text-red-500 text-xs italic p-2 bg-red-50 rounded border border-red-100 self-start">
                        Désolée, je n'arrive pas à me connecter. Vérifiez votre connexion.
                    </div>\`;
            }
            
            chatWindow.scrollTop = chatWindow.scrollHeight;
        }

        document.getElementById('user-input').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendMessage();
        });
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.orange[600],
          onPressed: _openChatbot,
          icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 28),
          label: const Text(
            'Khady',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
