import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reorderables/reorderables.dart';

import '../utils/minute_limit_formatter.dart';

class TripPlanSection extends StatefulWidget {
  final List<Map<String, TextEditingController>> controllers;
  final List<bool> isEditable;
  final Function(int index) onAdd;
  final Function(int index) onDelete;
  final Function(int oldIndex, int newIndex)? onReorder;
  final Function(int index, String? value) onAmPmChanged;
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;

  const TripPlanSection({
    Key? key,
    required this.controllers,
    required this.isEditable,
    required this.onAdd,
    required this.onDelete,
    this.onReorder,
    required this.onAmPmChanged,
    required this.fromTime,
    required this.toTime,
  }) : super(key: key);

  @override
  State<TripPlanSection> createState() => _TripPlanSectionState();
}

class _TripPlanSectionState extends State<TripPlanSection>
    with TickerProviderStateMixin {
  final Map<int, bool> _visibleMap = {};
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Map<int, FocusNode> _timeFocusNodes = {};
  Map<int, String?> _ampmSelections = {};
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _timeErrorMap = {};
  final Map<int, bool> _descErrorMap = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.controllers.length; i++) {
      _visibleMap[i] = true;
      _ampmSelections[i] = null;

      _timeFocusNodes[i] = FocusNode();
      _timeFocusNodes[i]!.addListener(() {
        if (!_timeFocusNodes[i]!.hasFocus) {
          final controller = widget.controllers[i]['time']!;
          final value = controller.text;
          final ampm = _ampmSelections[i];

          if (value == '1') {
            controller.text = '01:00';
          } else if (RegExp(r'^\d{2}:$').hasMatch(value)) {
            controller.text = value + '00';
          }

          if (RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
            final parts = value.split(':');
            final hour = parts[0];
            String minute = parts[1];
            if (int.tryParse(minute[0]) != null && int.parse(minute[0]) > 5) {
              minute = '5' + minute[1];
              controller.text = '$hour:$minute';
            }
          }

          final timeValid = _isTimeWithinRange(controller.text, ampm);

          setState(() {
            _timeErrorMap[i] = !timeValid;
          });

          if (!timeValid) {
            final reason = (widget.fromTime == null || widget.toTime == null)
                ? "⏰ Please select start and end time first."
                : "⏰ Time must be within selected range.";
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(reason)));
          }
        }
      });
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
    final timeText = widget.controllers[index]['time']!.text.trim();
    final descText = widget.controllers[index]['desc']!.text.trim();
    final ampm = _ampmSelections[index];

    final hasTime = timeText.isNotEmpty;
    final hasDesc = descText.isNotEmpty;
    final timeValid = _isTimeWithinRange(timeText, ampm);

    setState(() {
      _timeErrorMap[index] = !hasTime || !timeValid;
      _descErrorMap[index] = !hasDesc;
    });

    if (!hasTime || !hasDesc || !timeValid) return;

    widget.onAdd(index);

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _visibleMap[widget.controllers.length - 1] = false;
      });

      Future.delayed(const Duration(milliseconds: 150), () {
        setState(() {
          _visibleMap[widget.controllers.length - 1] = true;
        });

        // Auto-scroll after new card is visible
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        });
      });
    });
  }

  bool _isTimeWithinRange(String input, String? ampm) {
    if (input.length != 5 || !input.contains(':') || ampm == null)
      return false; // Now rejects if no bounds

    final parts = input.split(':');
    final int hour = int.tryParse(parts[0]) ?? -1;
    final int minute = int.tryParse(parts[1]) ?? -1;
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return false;

    final int hour24 = ampm == 'PM' && hour != 12
        ? hour + 12
        : (ampm == 'AM' && hour == 12 ? 0 : hour);
    final int totalMinutes = hour24 * 60 + minute;

    if (widget.fromTime == null || widget.toTime == null) return false;

    final int fromMinutes =
        widget.fromTime!.hour * 60 + widget.fromTime!.minute;
    final int toMinutes = widget.toTime!.hour * 60 + widget.toTime!.minute;

    return totalMinutes >= fromMinutes && totalMinutes <= toMinutes;
  }

  @override
  void dispose() {
    for (var node in _timeFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Trip Plan',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Divider(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 0),
            child: ReorderableWrap(
              spacing: 0,
              runSpacing: 0,
              scrollDirection: Axis.horizontal,
              needsLongPressDraggable: true,
              onReorder: widget.onReorder ?? (oldIndex, newIndex) {},
              children: List.generate(widget.controllers.length, (index) {
                final isLast = index == widget.controllers.length - 1;
                final timeController = widget.controllers[index]['time']!;
                final descController = widget.controllers[index]['desc']!;
                final editable = widget.isEditable[index];
                final isVisible = _visibleMap[index] ?? true;
                _timeFocusNodes.putIfAbsent(index, () {
                  final node = FocusNode();
                  node.addListener(() {
                    if (!node.hasFocus) {
                      final value = timeController.text;
                      if (value == '1') {
                        timeController.text = '01:00';
                      } else if (RegExp(r'^\d{2}:$').hasMatch(value)) {
                        timeController.text = value + '00';
                      }
                    }
                  });
                  return node;
                });

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
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 12, left: 12), // make space for ❌
                        child: SizedBox(
                          width: 230,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Main Card
                              Container(
                                width: 180,
                                constraints:
                                    const BoxConstraints(minHeight: 80),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.grey.shade700
                                        : const Color(0xFFCFCFCF),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDarkMode
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: timeController,
                                                focusNode:
                                                    _timeFocusNodes[index],
                                                readOnly: !editable,
                                                keyboardType:
                                                    TextInputType.datetime,
                                                inputFormatters: [
                                                  TimeFormatStrictFormatter(),
                                                ],
                                                style: TextStyle(
                                                  fontFamily: 'poppins',
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: 'Time',
                                                  isDense: true,
                                                  errorText:
                                                      _timeErrorMap[index] ==
                                                              true
                                                          ? 'Required'
                                                          : null,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                  border: InputBorder.none,
                                                  hintStyle: TextStyle(
                                                    color: isDarkMode
                                                        ? Colors.grey.shade500
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  if (value.contains(':') ||
                                                      value.length > 2) return;

                                                  final num =
                                                      int.tryParse(value);
                                                  if (num != null) {
                                                    if (num >= 2 &&
                                                        num <= 9 &&
                                                        value.length == 1) {
                                                      final formatted =
                                                          '0$num:';
                                                      timeController.value =
                                                          TextEditingValue(
                                                        text: formatted,
                                                        selection: TextSelection
                                                            .collapsed(
                                                                offset: formatted
                                                                    .length),
                                                      );
                                                    } else if ((num == 1 ||
                                                            num == 10 ||
                                                            num == 11 ||
                                                            num == 12) &&
                                                        value.length == 2) {
                                                      final formatted = value
                                                              .padLeft(2, '0') +
                                                          ':';
                                                      timeController.value =
                                                          TextEditingValue(
                                                        text: formatted,
                                                        selection: TextSelection
                                                            .collapsed(
                                                                offset: formatted
                                                                    .length),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            ToggleButtons(
                                              isSelected: [
                                                _ampmSelections[index] == 'AM',
                                                _ampmSelections[index] == 'PM'
                                              ],
                                              onPressed: (i) {
                                                final value =
                                                    i == 0 ? 'AM' : 'PM';
                                                setState(() {
                                                  _ampmSelections[index] =
                                                      value;
                                                });
                                                widget.onAmPmChanged(index,
                                                    value); // 👈 Send to parent
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              selectedColor: Colors.white,
                                              color: Colors.grey,
                                              fillColor: Colors.blue,
                                              constraints: const BoxConstraints(
                                                  minWidth: 40, minHeight: 28),
                                              renderBorder: false,
                                              children: const [
                                                Text('AM',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                Text('PM',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                        )),
                                    Divider(
                                      height: 1,
                                      color: isDarkMode
                                          ? Colors.grey.shade600
                                          : const Color(0xFFCFCFCF),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: TextField(
                                        controller: descController,
                                        readOnly: !editable,
                                        maxLines: null,
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Description',
                                          isDense: true,
                                          errorText:
                                              _descErrorMap[index] == true
                                                  ? 'Required'
                                                  : null,
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                            color: isDarkMode
                                                ? Colors.grey.shade500
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ❌ Delete Button
                              if (!editable)
                                Positioned(
                                  top: -10,
                                  right: 40,
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
                                            duration: const Duration(
                                                milliseconds: 150),
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              backgroundBlendMode:
                                                  BlendMode.screen,
                                              color: isPressed
                                                  ? Colors.grey.shade600
                                                  : isDarkMode
                                                      ? Colors.grey.shade800
                                                      : const Color.fromARGB(
                                                          255, 224, 224, 224),
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color.fromARGB(
                                                      66, 42, 42, 42),
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
                                top: 0,
                                bottom: 0,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade400,
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
                              ),

                              // ➕ Add Button
                              if (isLast)
                                Positioned(
                                  right: -20,
                                  top: 0,
                                  bottom: 0,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: _ampmSelections[index] == null
                                            ? null
                                            : () => animateAdd(index),
                                        child: Opacity(
                                          opacity:
                                              _ampmSelections[index] == null
                                                  ? 0.4
                                                  : 1.0,
                                          child: Container(
                                            width:
                                                40, // ⬅ slightly larger hit area
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? Colors.blue.shade200
                                                    : Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.add,
                                                  color: Colors.white,
                                                  size: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.info, size: 16, color: Colors.blue),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Enter time (1–12), choose AM/PM, and drag to reorder checkpoints.',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'poppins',
                  color: isDarkMode ? Colors.lightBlueAccent : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
