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
  Widget build(BuildContext context) {
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
                              AssetImage("assets/Pictures/cars.webp")),
                      const SizedBox(width: 8),
                      const Text("EVA",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'poppins')),
                    ],
                  ),
                ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isError
                      ? Colors.red[400]
                      : (isUser ? Colors.blue[400] : Colors.white),
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
                            fontFamily: "poppins",
                            fontSize: 14),
                      )
                    else if (!animatedMessageIndexes.contains(index))
                      AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            msg['text'],
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontFamily: "poppins",
                                fontSize: 14),
                            speed: Duration(milliseconds: 7),
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
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "poppins",
                            fontSize: 14),
                      ),
                    const SizedBox(height: 4),
                    if (msg['timestamp'] != null)
                      Text(
                        formatTimestamp(msg['timestamp']),
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser ? Colors.white70 : Colors.grey[600],
                          fontFamily: "poppins",
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
