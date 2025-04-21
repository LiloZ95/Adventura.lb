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
import 'dart:ui';

class AdventuraChatPage extends StatefulWidget {
  final String userName;
  final String userId;
  const AdventuraChatPage({
    Key? key, 
    required this.userName, 
    required this.userId
  }) : super(key: key);
  
  @override
  _AdventuraChatPageState createState() => _AdventuraChatPageState();
}

class _AdventuraChatPageState extends State<AdventuraChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  final Set<int> _animatedMessageIndexes = {};
  
  
  final Color _primaryColor = const Color(0xFF1E88E5);
  final Color _accentColor = const Color(0xFF00BCD4);
  final Color _bgColor = const Color(0xFFF5F7FA);
  final Color _userBubbleColor = const Color(0xFF1E88E5);
  final Color _botBubbleColor = const Color(0xFFFFFFFF);
  final Color _welcomeBgColor = const Color(0xFFE3F2FD);
  
  Widget buildQuickChip(String label, String textToSend) {
    return GestureDetector(
      onTap: () {
        _controller.text = textToSend;
        _sendMessage();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();
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
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final chatBox = await Hive.openBox('chatMessages');
    final stored = chatBox.get('messages_${widget.userId}');

    if (stored != null && stored is List) {
      
      final typedMessages = stored.map<Map<String, dynamic>>((msg) {
        final safeMsg = Map<String, dynamic>.from(msg);

        
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
    final box = await Hive.openBox('chatMessages');
    await box.put('messages_${widget.userId}', _messages);
  }

  Future<void> _clearChat() async {
    final box = await Hive.openBox('chatMessages');
    await box.delete('messages_${widget.userId}');

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

    await box.put('messages_${widget.userId}', _messages);
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
    await _saveMessagesToHive();

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
      await _saveMessagesToHive();
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
      await _saveMessagesToHive();
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
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "EVA",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "EVA Adventure Assistant",
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Your Lebanon adventure guide",
                  style: TextStyle(
                    fontFamily: "poppins",
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            ),
            tooltip: "Clear chat",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      "Clear Chat",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      "Are you sure you want to delete all messages?",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Clear",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              if (confirm == true) {
                await _clearChat();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryColor,
              _primaryColor.withOpacity(0.8),
              _primaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _botBubbleColor,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: BouncingDotsLoader(
                                    size: 8,
                                    color: _primaryColor,
                                  ),
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
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: index > 0 ? 16 : 0,
                              left: isUser ? MediaQuery.of(context).size.width * 0.15 : 0,
                              right: isUser ? 0 : MediaQuery.of(context).size.width * 0.15,
                            ),
                            child: Column(
                              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? _userBubbleColor
                                        : isWelcome
                                            ? _welcomeBgColor
                                            : _botBubbleColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(isUser ? 18 : 4),
                                      topRight: Radius.circular(isUser ? 4 : 18),
                                      bottomLeft: const Radius.circular(18),
                                      bottomRight: const Radius.circular(18),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isUser
                                            ? _userBubbleColor.withOpacity(0.2)
                                            : Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isWelcome)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: _primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.travel_explore,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "EVA",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _primaryColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Text(
                                        msg['text'],
                                        style: TextStyle(
                                          color: isUser ? Colors.white : Colors.black87,
                                          fontSize: 15,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (msg['timestamp'] != null && !isError)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                _formatTimestamp(msg['timestamp']),
                                                style: TextStyle(
                                                  color: isUser ? Colors.white70 : Colors.black45,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              if (isUser)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 4),
                                                  child: Icon(
                                                    Icons.check_circle,
                                                    size: 12,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                
                                
                                if (!isUser && isWelcome)
                                  Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        buildQuickChip("❓ What is Adventura?", "What is Adventura?"),
                                        buildQuickChip("📆 How do I book?", "How do I book an activity?"),
                                        buildQuickChip("📍 Locations", "What locations do you support"),
                                        buildQuickChip("🚗 Car Events", "Show me some car events"),
                                        buildQuickChip("🌊 Sea trips", "Can you suggest some sea trips in Tripoli?"),
                                        buildQuickChip("💰 Become organizer", "how can i become a organizer?"),
                                      ],
                                    ),
                                  ),
                                
                                
                                if (!isUser && msg['cards'] != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: msg['cards']
                                          .asMap()
                                          .entries
                                          .map<Widget>((entry) {
                                        final i = entry.key;
                                        final card = entry.value;
                                        
                                        
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: SlideTransitionCard(card: card, index: i),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Ask EVA something...",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: const TextStyle(fontSize: 15),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryColor, _accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
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
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}


class BouncingDotsLoader extends StatefulWidget {
  final double size;
  final Color color;
  
  const BouncingDotsLoader({
    Key? key,
    this.size = 8.0,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  _BouncingDotsLoaderState createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller1, curve: Curves.easeInOut),
    );
    
    _animation2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller2, curve: Curves.easeInOut),
    );
    
    _animation3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller3, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) _controller2.repeat(reverse: true);
    });
    
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) _controller3.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(_animation1),
        SizedBox(width: widget.size / 2),
        _buildDot(_animation2),
        SizedBox(width: widget.size / 2),
        _buildDot(_animation3),
      ],
    );
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -4 * animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}


class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputBar({
    Key? key,
    required this.controller,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Ask EVA something...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 15),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1E88E5), const Color(0xFF00BCD4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isUser;
  final bool isError;
  final bool isWelcome;
  final int index;
  final Set<int> animatedMessageIndexes;
  final VoidCallback onAnimationFinished;

  const MessageBubble({
    Key? key,
    required this.msg,
    required this.isUser,
    required this.isError,
    required this.isWelcome,
    required this.index,
    required this.animatedMessageIndexes,
    required this.onAnimationFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isUser
        ? const Color(0xFF1E88E5)
        : isWelcome
            ? const Color(0xFFE3F2FD)
            : Colors.white;
            
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 18 : 4),
          topRight: Radius.circular(isUser ? 4 : 18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? const Color(0xFF1E88E5).withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWelcome)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E88E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.travel_explore,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "EVA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            msg['text'],
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          if (msg['timestamp'] != null && !isError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Text(
                    _formatTimestamp(msg['timestamp']),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                  if (isUser)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}