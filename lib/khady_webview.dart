import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KhadyWebView extends StatefulWidget {
  const KhadyWebView({super.key});

  @override
  State<KhadyWebView> createState() => _KhadyWebViewState();
}

class _KhadyWebViewState extends State<KhadyWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(_getHtmlContent());
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
        #khady-widget-container .chat-container { display: none; }
        #khady-widget-container.chat-active .chat-container { display: flex; }
        #khady-widget-container.chat-active .speech-bubble { display: none; }

        .speech-bubble {
            animation: khady-float 3s ease-in-out infinite;
            position: fixed;
            bottom: 140px;
            right: 20px;
            background: #ea580c;
            color: white;
            padding: 10px 15px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            z-index: 10000;
        }

        .speech-bubble::after {
            content: '';
            position: absolute;
            bottom: -8px;
            right: 30px;
            border-left: 10px solid transparent;
            border-right: 10px solid transparent;
            border-top: 10px solid #ea580c;
        }

        .bot-message strong { font-weight: 800; color: #1a1a1a; }
        .bot-message p { margin-bottom: 8px; }
        .bot-message ul { list-style-type: disc; margin-left: 20px; margin-bottom: 8px; }

        @keyframes khady-float {
            0%, 100% { transform: translateY(0); opacity: 0.9; }
            50% { transform: translateY(-10px); opacity: 1; }
        }

        #chat-window::-webkit-scrollbar { width: 5px; }
        #chat-window::-webkit-scrollbar-track { background: #f1f1f1; }
        #chat-window::-webkit-scrollbar-thumb { background: #ea580c; border-radius: 10px; }
    </style>
</head>
<body class="bg-transparent">

    <div id="khady-widget-container" class="fixed bottom-5 right-5 z-[9999] flex flex-col items-end">
        
        <div class="speech-bubble">Besoin d'aide ? Discutez avec Khady ! 👋</div>

        <div class="chat-container bg-white w-80 sm:w-[400px] rounded-2xl shadow-2xl flex-col overflow-hidden mb-4 border border-gray-200">
            <div class="bg-orange-600 p-4 text-white font-bold flex justify-between items-center">
                <div class="flex items-center gap-2">
                    <div class="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                    <span>Khady - Assistant YOBULMA</span>
                </div>
                <button onclick="toggleChat()" class="text-white hover:text-gray-200 text-xl font-bold">✕</button>
            </div>
            
            <div id="chat-window" class="h-[450px] overflow-y-auto p-4 space-y-4 bg-gray-50 text-sm flex flex-col">
                <div class="bg-orange-100 p-3 rounded-xl rounded-tl-none text-gray-800 self-start max-w-[90%] border border-orange-200 shadow-sm">
                    Salam ! Je suis <b>Khady</b>. Comment puis-je vous aider aujourd'hui ?
                </div>
            </div>

            <div class="p-3 border-t bg-white flex gap-2">
                <input type="text" id="user-input" autocomplete="off" placeholder="Écrivez votre message..." class="flex-1 border rounded-full px-4 py-2 focus:outline-none focus:border-orange-500 text-sm">
                <button onclick="sendMessage()" class="bg-orange-600 text-white px-5 py-2 rounded-full hover:bg-orange-700 transition font-medium">OK</button>
            </div>
        </div>

        <div class="cursor-pointer transition-all duration-300 hover:scale-110" onclick="toggleChat()">
            <dotlottie-wc
                src="https://lottie.host/9dd5ef52-995a-4c90-a14d-0c18761f9ac8/msW90Enhuj.lottie"
                style="width: 150px; height: 150px"
                autoplay
                loop>
            </dotlottie-wc>
        </div>
    </div>

    <script>
        const API_URL = "https://chatyobulma.onrender.com/chat";

        function toggleChat() {
            document.getElementById('khady-widget-container').classList.toggle('chat-active');
        }

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
    return WebViewWidget(controller: controller);
  }
}
