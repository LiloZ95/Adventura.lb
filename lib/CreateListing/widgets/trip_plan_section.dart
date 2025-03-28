import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class TripPlanSection extends StatefulWidget {
  final List<Map<String, TextEditingController>> controllers;
  final List<bool> isEditable;
  final Function(int index) onAdd;
  final Function(int index) onDelete;
  final Function(int oldIndex, int newIndex)? onReorder;

  const TripPlanSection({
    Key? key,
    required this.controllers,
    required this.isEditable,
    required this.onAdd,
    required this.onDelete,
    this.onReorder,
  }) : super(key: key);

  @override
  State<TripPlanSection> createState() => _TripPlanSectionState();
}

class _TripPlanSectionState extends State<TripPlanSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: const [
            Text(
              'Trip Plan',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),

        // Reorderable horizontal list
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ReorderableWrap(
            spacing: 0,
            scrollDirection: Axis.horizontal,
            needsLongPressDraggable: true,
            onReorder: (oldIndex, newIndex) {
              // Don't allow swapping with an editable card
              final fromEditable = widget.isEditable[oldIndex];
              final toEditable = widget.isEditable[newIndex];

              if (fromEditable || toEditable) {
                return; // Do nothing
              }

              setState(() {
                final movedController = widget.controllers.removeAt(oldIndex);
                widget.controllers.insert(newIndex, movedController);

                final movedEditable = widget.isEditable.removeAt(oldIndex);
                widget.isEditable.insert(newIndex, movedEditable);
              });
            },
            children: List.generate(widget.controllers.length, (index) {
              final isLast = index == widget.controllers.length - 1;
              final timeController = widget.controllers[index]['time']!;
              final descController = widget.controllers[index]['desc']!;
              final editable = widget.isEditable[index];

              return Container(
                key: ValueKey("trip_$index"),
                width: 230,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Card UI
                    Container(
                      width: 180,
                      constraints: const BoxConstraints(minHeight: 80),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCFCFCF)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: TextField(
                              controller: timeController,
                              readOnly: !editable,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Time',
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontFamily: 'poppins'),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final num = int.tryParse(value);
                                  if (num != null &&
                                      num >= 1 &&
                                      num <= 12 &&
                                      value.length < 3) {
                                    final formatted =
                                        num.toString().padLeft(2, '0') + ':00';
                                    timeController.value = TextEditingValue(
                                      text: formatted,
                                      selection: TextSelection.collapsed(
                                          offset: formatted.length),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFCFCFCF)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: TextField(
                              controller: descController,
                              readOnly: !editable,
                              decoration: const InputDecoration(
                                hintText: 'Description',
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontFamily: 'poppins'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ❌ Delete Button
                    if (!editable)
                      Positioned(
                        top: 6,
                        right: 50,
                        child: GestureDetector(
                          onTap: () => widget.onDelete(index),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.red),
                        ),
                      ),

                    // 🔢 Number Badge (middle-right)
                    Positioned(
                      right: 40,
                      top: 36,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),

                    // ➕ Add Button
                    if (isLast)
                      Positioned(
                        top: 32,
                        right: -5,
                        child: GestureDetector(
                          onTap: () => widget.onAdd(index),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 50),
        const SizedBox(height: 10),
        Row(
          children: const [
            Icon(Icons.info, size: 16, color: Colors.blue),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Enter time (1–12), choose AM/PM, and drag to reorder checkpoints.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontFamily: 'poppins',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
