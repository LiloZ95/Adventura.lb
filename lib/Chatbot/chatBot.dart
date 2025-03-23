import 'package:adventura/Chatbot/activityCard.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdventuraChatPage extends StatefulWidget {
  const AdventuraChatPage({Key? key}) : super(key: key);

  @override
  _AdventuraChatPageState createState() => _AdventuraChatPageState();
}

class _AdventuraChatPageState extends State<AdventuraChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({'text': _controller.text.trim(), 'isUser': true});
      _isTyping = true;
    });

    try {
      final botResponse = await sendMessageToBot(_controller.text.trim());
      setState(() {
        _messages.add({
          'text': botResponse['chatbot_reply'],
          'isUser': false,
          'cards': botResponse['cards']
        });
        _isTyping = false;
      });
    } catch (e) {
      print("Bot API call failed: $e");
      setState(() => _isTyping = false);
    }

    _controller.clear();
  }

  Future<Map<String, dynamic>> sendMessageToBot(String query) async {
    const apiUrl =
        "https://ec0d-34-142-181-41.ngrok-free.app/chat"; // Replace with your ngrok URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "query": query,
        "category_id": 1, // Optional, you can dynamically extract later
        "location": "Tripoli"
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get response from bot");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Adventura AI Assistant"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  // Typing indicator
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.circle, size: 10, color: Colors.grey),
                        SizedBox(width: 8),
                        Text("Adventura is typing...",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['isUser'] ?? false;

                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[400] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      if (!isUser && msg['cards'] != null)
                        ...msg['cards'].map<Widget>(
                            (card) => SlideTransitionCard(card: card))
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue[400],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SlideTransitionCard extends StatefulWidget {
  final Map<String, dynamic> card;

  const SlideTransitionCard({Key? key, required this.card}) : super(key: key);

  @override
  State<SlideTransitionCard> createState() => _SlideTransitionCardState();
}

class _SlideTransitionCardState extends State<SlideTransitionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return SlideTransition(
      position: _offsetAnimation,
      child: ActivityCard(
        name: card['name'],
        description: card['description'],
        price: card['price'],
        duration: card['duration'],
        seats: card['seats'],
        location: card['location'],
      ),
    );
  }
}
