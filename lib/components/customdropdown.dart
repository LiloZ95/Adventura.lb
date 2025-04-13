// lib/widgets/creative_location_dropdown.dart
import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';

class CreativeLocationDropdown extends StatefulWidget {
  final String selectedLocation;
  final List<String> locations;
  final Function(String) onLocationChanged;
  final Color accentColor;
  final double width;
  final bool showLocationPrefix;

  const CreativeLocationDropdown({
    Key? key,
    required this.selectedLocation,
    required this.locations,
    required this.onLocationChanged,
    this.accentColor = const Color(0xFF3D5A8E), // Default to AppColors.mainBlue
    this.width = 180.0,
    this.showLocationPrefix = true,
  }) : super(key: key);

  @override
  _CreativeLocationDropdownState createState() => _CreativeLocationDropdownState();
}

class _CreativeLocationDropdownState extends State<CreativeLocationDropdown> with SingleTickerProviderStateMixin {
  bool _isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _heightAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      if (_isDropdownOpen) {
        _animationController.forward();
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        _animationController.reverse();
        _removeOverlay();
      }
    });
  }

  void _closeDropdown() {
    if (_isDropdownOpen) {
      setState(() {
        _isDropdownOpen = false;
        _animationController.reverse();
        _removeOverlay();
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                width: widget.width + 20,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(-10.0, size.height - 5),
                  child: AnimatedBuilder(
                    animation: _heightAnimation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Material(
                          elevation: 0, // No elevation, we'll use a custom shadow
                          color: Colors.transparent,
                          child: Container(
                            height: _heightAnimation.value * (widget.locations.length * 50 + 20),
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: _heightAnimation.value,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Small decorative element at the top
                                  Container(
                                    width: 40,
                                    height: 4,
                                    margin: EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Location items
                                  ...widget.locations.map((location) {
                                    final bool isSelected = location == widget.selectedLocation;
                                    return _buildLocationItem(location, isSelected);
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationItem(String location, bool isSelected) {
    return InkWell(
      onTap: () {
        widget.onLocationChanged(location);
        _closeDropdown();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 15),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? widget.accentColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Location icon with gradient background
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [widget.accentColor, widget.accentColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            SizedBox(width: 10),
            // Location name
            Text(
              location,
              style: TextStyle(
                color: isSelected ? widget.accentColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
            Spacer(),
            // Selected checkmark
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLocationPrefix)
            Text(
              "Location:   ",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
            ),
          CompositedTransformTarget(
            link: _layerLink,
            child: InkWell(
              onTap: _toggleDropdown,
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 4),
                decoration: BoxDecoration(
                  color: _isHovered || _isDropdownOpen 
                      ? widget.accentColor.withOpacity(0.08)
                      : Color.fromRGBO(124, 124, 124, 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isDropdownOpen 
                        ? widget.accentColor.withOpacity(0.5) 
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current location icon
                    Container(
                      width: 28,
                      height: 28,
                      padding: EdgeInsets.all(6),
                     
                      child: Icon(
                        Icons.location_on,
                        size: 16,
                        color: widget.accentColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    // Current selected location
                    Text(
                      widget.selectedLocation,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Animated rotation arrow
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: _isDropdownOpen ? widget.accentColor : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}