import 'package:flutter/material.dart';

class KhadyChatWrapper extends StatefulWidget {
  final Widget child;
  const KhadyChatWrapper({super.key, required this.child});

  @override
  State<KhadyChatWrapper> createState() => _KhadyChatWrapperState();
}

class _KhadyChatWrapperState extends State<KhadyChatWrapper> {
  bool _isChatOpen = false;
  bool _isTyping = false;
  List<Map<String, String>> _messages = []; // Liste pour stocker la simulation

  // Suggestions de messages
  final List<String> _suggestions = [
    "Comment suivre ma commande ?",
    "Quels sont les tarifs de livraison ?",
  ];

  void _simulateSend(String text) async {
    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isTyping = true; // Active le loader
    });

    // Simule une attente de 3 secondes avant que Khady ne "réponde" (ou reste en attente)
    await Future.delayed(const Duration(seconds: 3));

    // Ici on pourrait ajouter une réponse auto, mais pour votre demande
    // on laisse juste le loader ou on le coupe selon votre envie.
    // setState(() { _isTyping = false; });
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final isExcluded =
        routeName == '/login' ||
        routeName == '/register' ||
        routeName == '/welcome';

    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          if (_isChatOpen)
            Positioned(
              right: 20,
              bottom: 90,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9800),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 15,
                              child: Icon(
                                Icons.smart_toy,
                                size: 18,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Khady",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _isChatOpen = false),
                            ),
                          ],
                        ),
                      ),

                      // Zone des messages
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(10),
                          children: [
                            const Text(
                              "Bonjour ! Je suis Khady. Comment puis-je vous aider ?",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Affichage des messages envoyés
                            ..._messages.map(
                              (m) => Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF9800),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    m["text"]!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),

                            // Loader "Khady écrit..."
                            if (_isTyping)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Khady est en train de répondre...",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Suggestions (si aucun message n'est encore envoyé ou pour simuler)
                      if (!_isTyping && _messages.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: _suggestions
                                .map(
                                  (s) => ActionChip(
                                    label: Text(
                                      s,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    onPressed: () => _simulateSend(s),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      const Divider(),
                      // Input (décoratif)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          readOnly: true, // Désactivé pour la simulation
                          decoration: InputDecoration(
                            hintText: "Écrire à Khady...",
                            hintStyle: const TextStyle(fontSize: 13),
                            suffixIcon: const Icon(
                              Icons.send,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bouton flottant
          if (!isExcluded)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFFF9800),
                onPressed: () => setState(() => _isChatOpen = !_isChatOpen),
                child: Icon(
                  _isChatOpen ? Icons.keyboard_arrow_down : Icons.smart_toy,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
