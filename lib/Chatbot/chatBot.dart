import 'package:adventura/Chatbot/gradientChip.dart';
import 'package:adventura/Chatbot/inputBar.dart';
import 'package:adventura/Chatbot/messageBubble.dart';
import 'package:adventura/Chatbot/slideTransitionCard.dart';
import 'package:adventura/widgets/bouncing_dots_loader.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adventura/config.dart';

class AdventuraChatPage extends StatefulWidget {
  final String userName;
  final String userId;
  const AdventuraChatPage(
      {Key? key, required this.userName, required this.userId})
      : super(key: key);
  @override
  _AdventuraChatPageState createState() => _AdventuraChatPageState();
}

class _AdventuraChatPageState extends State<AdventuraChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  final Set<int> _animatedMessageIndexes = {};
  Widget buildQuickChip(String label, String textToSend) {
    return GradientChip(
      label: label,
      onTap: () {
        _controller.text = textToSend;
        _sendMessage();
      },
    );
  }

  final ScrollController _scrollController = ScrollController();
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
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
  void initState() {
    super.initState();
    _loadMessages(); // this handles everything
  }

  Future<void> _loadMessages() async {
    final chatBox = await Hive.openBox('chatMessages');
    final stored = chatBox.get('messages_${widget.userId}');

    if (stored != null && stored is List) {
      // Step 1: Convert each msg to Map<String, dynamic>
      final typedMessages = stored.map<Map<String, dynamic>>((msg) {
        final safeMsg = Map<String, dynamic>.from(msg);

        // Step 2: If there's a cards list, cast each card inside it
        if (safeMsg['cards'] != null && safeMsg['cards'] is List) {
          final rawCards = safeMsg['cards'] as List;
          safeMsg['cards'] = rawCards
              .map<Map<String, dynamic>>(
                (card) => Map<String, dynamic>.from(card),
              )
              .toList();
        }

        return safeMsg;
      }).toList();

      setState(() {
        _messages.addAll(typedMessages);
        for (int i = 0; i < typedMessages.length; i++) {
          _animatedMessageIndexes.add(i);
        }
      });
    } else {
      setState(() {
        _messages.add({
          'text': "Welcome 👋 This is EVA — your adventure assistant here in Lebanon!\n\n"
              "Here's what it can help you with:\n"
              "✨ Suggest fun things to do\n"
              "📍 Find activities near a place — like 'Show me something in Batroun'\n"
              "🎟️ Help you book activities and trips\n"
              "💬 Answer common questions — like pricing, refunds, group discounts\n\n"
              "Ready to explore? Ask anything travel-related — or tap one of the quick options below to get started! 🧭",
          'isUser': false,
          'cards': [],
          'isWelcome': true,
          'timestamp': DateTime.now(),
        });
        _animatedMessageIndexes.add(0);
      });

      await chatBox.put('messages_${widget.userId}', _messages);
    }
  }

  Future<void> _saveMessagesToHive() async {
    final box = await Hive.openBox('chatMessages'); // ✅
    await box.put('messages_${widget.userId}', _messages);
  }

  Future<void> _clearChat() async {
    final box = await Hive.openBox('chatMessages');
    await box.delete('messages_${widget.userId}'); // ✅ correct key

    setState(() {
      _messages.clear();
      _animatedMessageIndexes.clear();
      _messages.add({
        'text': "Welcome 👋 This is EVA — your adventure assistant here in Lebanon!\n\n"
            "Here's what it can help you with:\n"
            "✨ Suggest fun things to do\n"
            "📍 Find activities near a place — like 'Show me something in Batroun'\n"
            "🎟️ Help you book activities and trips\n"
            "💬 Answer common questions — like pricing, refunds, group discounts\n\n"
            "Ready to explore? Ask anything travel-related — or tap one of the quick options below to get started! 🧭",
        'isUser': false,
        'cards': [],
        'isWelcome': true,
        'timestamp': DateTime.now(),
      });
      _animatedMessageIndexes.add(0);
    });

    await box.put('messages_${widget.userId}', _messages); // 🧠 Re-save fresh
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    final now = DateTime.now();
    _controller.clear();
    _scrollToBottom();

    setState(() {
      _messages.add({
        'text': userMessage,
        'isUser': true,
        'timestamp': now,
      });
      _isTyping = true;
    });
    await _saveMessagesToHive(); // 💾 Save after user sends

    try {
      final botResponse = await sendMessageToBot(
        userMessage,
        userName: widget.userName,
      );

      setState(() {
        _messages.add({
          'text': botResponse['chatbot_reply'],
          'isUser': false,
          'cards': botResponse['cards'],
          'timestamp': DateTime.now(),
        });
        _isTyping = false;
      });
      await _saveMessagesToHive(); // 💾 Save after bot responds
      _scrollToBottom();
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
      await _saveMessagesToHive(); // 💾 Still save fallback message
      _scrollToBottom();
    }
  }

  Future<Map<String, dynamic>> sendMessageToBot(String query,
      {String? userName}) async {
    const apiUrl = "$chabotUrl/chat";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "query": query,
        "username": userName,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "EVA Adventure Chatbot",
          style: TextStyle(
            fontFamily: "poppins",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: "Clear chat",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Clear Chat"),
                  content: const Text(
                      "Are you sure you want to delete all messages?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Clear",
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await _clearChat();
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // 👈 this!
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
                          child: const BouncingDotsLoader(size: 7),
                        ),
                      ],
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['isUser'] ?? false;
                final isError = msg['isError'] ?? false;
                final isWelcome = msg['isWelcome'] ?? false;

                return AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 400),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            MessageBubble(
                              msg: msg,
                              isUser: isUser,
                              isError: isError,
                              isWelcome: isWelcome,
                              index: index,
                              animatedMessageIndexes: _animatedMessageIndexes,
                              onAnimationFinished: () {
                                setState(() {
                                  _animatedMessageIndexes.add(index);
                                });
                              },
                            ),
                            if (!isUser && isWelcome)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        buildQuickChip("❓ What is Adventura?",
                                            "What is Adventura?"),
                                        buildQuickChip("📆 How do I book?",
                                            "How do I book an activity?"),
                                        buildQuickChip(
                                            "📍 What locations do you support",
                                            "What locations do you support"),
                                        buildQuickChip("🚗 Car Events near me",
                                            "Show me some car events"),
                                        buildQuickChip(
                                            "🌊 Sea trips in Tripoli",
                                            "Can you suggest some sea trips in Tripoli?"),
                                        buildQuickChip(
                                            "💰 how can i become a organizer?",
                                            "how can i become a organizer?"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (!isUser && msg['cards'] != null)
                              ...msg['cards']
                                  .asMap()
                                  .entries
                                  .map<Widget>((entry) {
                                final i = entry.key;
                                final card = entry.value;
                                return SlideTransitionCard(
                                    card: card, index: i);
                              }),
                          ],
                        ),
                      ),
                    ));
              },
            ),
          ),
          ChatInputBar(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
