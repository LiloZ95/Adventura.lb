import 'package:adventura/Chatbot/activityCard.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/widgets/bouncing_dots_loader.dart';
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

    final userMessage = _controller.text.trim();

    _controller.clear();

    setState(() {
      _messages.add({'text': userMessage, 'isUser': true});
      _isTyping = true;
    });

    try {
      final botResponse = await sendMessageToBot(userMessage);
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
      setState(() {
        _messages.add({
          'text': "⚠️ Something went wrong. Failed to fetch data.",
          'isUser': false,
          'isError': true
        });
        _isTyping = false;
      });
    }
  }

  Future<Map<String, dynamic>> sendMessageToBot(String query) async {
    const apiUrl =
        "https://e468-34-125-120-105.ngrok-free.app/chat"; // Replace with your ngrok URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "query": query,
        "category_id": 1, // Optional, you can dynamically extract later
        "location": "Tripoli",
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
        backgroundColor: Colors.blue,
        // centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen
          },
        ),
        title: const Text(
          "EVA Adventure Chatbot",
          style: TextStyle(
            fontFamily: "poppins",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const BouncingDotsLoader(
                            size: 7,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['isUser'] ?? false;
                final isError = msg['isError'] ?? false;

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
                          color: isError
                              ? Colors.red[400]
                              : (isUser ? Colors.blue[400] : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            color: isError
                                ? Colors.white
                                : (isUser ? Colors.white : Colors.black),
                            fontFamily: "poppins",
                          ),
                        ),
                      ),
                      if (!isUser && msg['cards'] != null)
                        ...msg['cards'].asMap().entries.map<Widget>((entry) {
                          final i = entry.key;
                          final card = entry.value;
                          return SlideTransitionCard(card: card, index: i);
                        }),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      hintText: "Type your message...",
                      hintStyle: const TextStyle(fontFamily: "poppins"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.grey0, // Blue border color
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors
                              .grey3, // Blue border color when not focused
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Blue border color when focused
                          width: 2,
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
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
  final int index; // 🆕 used for staggering animation

  const SlideTransitionCard({
    Key? key,
    required this.card,
    required this.index,
  }) : super(key: key);

  @override
  State<SlideTransitionCard> createState() => _SlideTransitionCardState();
}

class _SlideTransitionCardState extends State<SlideTransitionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Staggered delay based on index
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
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
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ActivityCard(
          name: card['name'],
          description: card['description'],
          price: card['price'],
          duration: card['duration'],
          seats: card['seats'],
          location: card['location'],
        ),
      ),
    );
  }
}
