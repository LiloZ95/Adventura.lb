import "package:animated_text_kit/animated_text_kit.dart";
import "package:flutter/material.dart";

String formatTimestamp(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return "$hour:$minute";
}

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isUser;
  final bool isError;
  final bool isWelcome;
  final int index;
  final Set<int> animatedMessageIndexes;
  final Function() onAnimationFinished;

  const MessageBubble({
    super.key,
    required this.msg,
    required this.isUser,
    required this.isError,
    required this.isWelcome,
    required this.index,
    required this.animatedMessageIndexes,
    required this.onAnimationFinished,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 400),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundImage:
                            AssetImage("assets/Pictures/cars.webp"),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "EVA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isError
                      ? Colors.red[400]
                      : (isUser
                          ? Colors.blue[400]
                          : isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (isUser)
                      Text(
                        msg['text'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontSize: 14,
                        ),
                      )
                    else if (!animatedMessageIndexes.contains(index))
                      AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            msg['text'],
                            textStyle: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontFamily: "Poppins",
                              fontSize: 14,
                            ),
                            speed: const Duration(milliseconds: 7),
                          ),
                        ],
                        isRepeatingAnimation: false,
                        totalRepeatCount: 1,
                        displayFullTextOnTap: true,
                        onFinished: onAnimationFinished,
                      )
                    else
                      Text(
                        msg['text'],
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: "Poppins",
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (msg['timestamp'] != null)
                      Text(
                        formatTimestamp(msg['timestamp']),
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser
                              ? Colors.white70
                              : (isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600]),
                          fontFamily: "Poppins",
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
}
