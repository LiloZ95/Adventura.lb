import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<bool> isEditable;
  final Function(int index) onAdd;
  final Function(int index) onDelete;

  const FeaturesSection({
    Key? key,
    required this.controllers,
    required this.isEditable,
    required this.onAdd,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: const [
            Text(
              'Features',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),

        // Feature Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(controllers.length, (index) {
              final controller = controllers[index];
              final editable = isEditable[index];

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    IntrinsicWidth(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 50),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: editable ? null : const Color(0xFFF5F5F5),
                          border: Border.all(
                            color: const Color(0xFFCFCFCF),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: TextField(
                                controller: controller,
                                readOnly: !editable,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: editable
                                      ? 'Ex: Entertainment'
                                      : null,
                                  hintStyle: const TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            // ❌ Delete button for locked pills
                            if (!editable)
                              GestureDetector(
                                onTap: () => onDelete(index),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 6.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ➕ Button on the last one
                    if (index == controllers.length - 1)
                      const SizedBox(width: 8),
                    if (index == controllers.length - 1)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add,
                              color: Colors.white, size: 16),
                          onPressed: () => onAdd(index),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 8),

        // Info text
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info, color: Colors.blue, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Add what's featured in the activity/event.",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
