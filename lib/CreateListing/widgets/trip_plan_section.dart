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

class _TripPlanSectionState extends State<TripPlanSection>
    with TickerProviderStateMixin {
  final Map<int, bool> _visibleMap = {};
  final Duration _animationDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.controllers.length; i++) {
      _visibleMap[i] = true;
    }
  }

  void animateDelete(int index) {
    setState(() {
      _visibleMap[index] = false;
    });
    Future.delayed(_animationDuration, () {
      widget.onDelete(index);
      setState(() {
        _visibleMap.remove(index);
      });
    });
  }

  void animateAdd(int index) {
    widget.onAdd(index);

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _visibleMap[widget.controllers.length - 1] = false;
      });

      Future.delayed(Duration(milliseconds: 150), () {
        setState(() {
          _visibleMap[widget.controllers.length - 1] = true;
        });
      });
    });
  }

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
          padding: const EdgeInsets.only(right: 40), // add this line
          child: ReorderableWrap(
            spacing: 0,
            scrollDirection: Axis.horizontal,
            needsLongPressDraggable: true,
            onReorder: (oldIndex, newIndex) {
              final fromEditable = widget.isEditable[oldIndex];
              final toEditable = widget.isEditable[newIndex];

              if (fromEditable || toEditable) return;

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
              final isVisible = _visibleMap[index] ?? true;

              return AnimatedOpacity(
                key: ValueKey("trip_$index"),
                opacity: isVisible ? 1.0 : 0.0,
                duration: _animationDuration,
                child: AnimatedScale(
                  scale: isVisible ? 1.0 : 0.9,
                  duration: _animationDuration,
                  curve: Curves.easeInOut,
                  child: AnimatedSize(
                    duration: _animationDuration,
                    curve: Curves.easeInOut,
                    child: Container(
                      width: 230,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Card UI
                          Container(
                            width: 180,
                            constraints: const BoxConstraints(
                              minHeight: 80,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFCFCFCF)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                                              num.toString().padLeft(2, '0') +
                                                  ':00';
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
                                    maxLines: null, // let it grow
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
                              right: 55,
                              child: Builder(builder: (context) {
                                bool isPressed = false;

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return GestureDetector(
                                      onTapDown: (_) {
                                        setState(() => isPressed = true);
                                      },
                                      onTapUp: (_) {
                                        setState(() => isPressed = false);
                                        animateDelete(index);
                                      },
                                      onTapCancel: () {
                                        setState(() => isPressed = false);
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isPressed
                                              ? const Color.fromARGB(255, 145, 145, 145)
                                              : const Color.fromARGB(255, 224, 224, 224),
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color.fromARGB(66, 42, 42, 42),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),

                          // 🔢 Number Badge
                          Positioned(
                            right: 40,
                            top: 40,
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
                              top: 34,
                              right: -5,
                              child: GestureDetector(
                                onTap: () => animateAdd(index),
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
                    ),
                  ),
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
