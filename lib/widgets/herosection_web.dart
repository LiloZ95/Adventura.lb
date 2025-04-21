import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';
import 'dart:math' as math;
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:scroll_to_index/scroll_to_index.dart'; 

class HeroSectionWidget extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onSearchTap;
  final AutoScrollController ?scrollController; 

  const HeroSectionWidget({
    Key? key,
    required this.isLoading,
    required this.onSearchTap,
    this.scrollController, 
  }) : super(key: key);

  @override
  State<HeroSectionWidget> createState() => _HeroSectionWidgetState();
}

class _HeroSectionWidgetState extends State<HeroSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _searchBarController;
  late AnimationController _bounceController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchBarAnimation;
  late Animation<double> _bounceAnimation;
  static const int ACTIVITIES_SECTION_INDEX = 1;

  late AnimationController _parallaxController;
  late AnimationController _particleController;
  late AnimationController _blueOverlayController;
  late Animation<double> _blueOverlayAnimation;

  int _selectedCategoryIndex = -1;
  final List<String> _categories = ['Hiking', 'Water Sports', 'Food Tours', 'Cultural', 'Adventure'];

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
    
    _parallaxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), 
    )..repeat();
    
    _blueOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    
    _blueOverlayAnimation = Tween<double>(begin: 0.15, end: 0.25).animate(
      CurvedAnimation(parent: _blueOverlayController, curve: Curves.easeInOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), 
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController, 
        curve: const Interval(0.1, 0.8, curve: Curves.easeIn)
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController, 
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuint)
      ),
    );

    _searchBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _searchBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchBarController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
      Future.delayed(const Duration(milliseconds: 700), () {
        _searchBarController.forward();
      });
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _searchBarController.dispose();
    _bounceController.dispose();
    _parallaxController.dispose();
    _particleController.dispose();
    _blueOverlayController.dispose();
    super.dispose();
  }
  
  void _scrollToActivities() async {
    await widget.scrollController!.scrollToIndex(
      ACTIVITIES_SECTION_INDEX, 
      preferPosition: AutoScrollPosition.begin,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    final heroHeight = isMobile ? 600.0 : 750.0;

    return widget.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_backgroundController, _blueOverlayController]),
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    height: heroHeight,
                    child: Stack(
                      children: [
                        Transform.scale(
                          scale: _backgroundAnimation.value,
                          alignment: Alignment.center,
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent, 
                                  Colors.black.withOpacity(0.5), 
                                ],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.darken,
                            child: Image.asset(
                              'assets/Pictures/sunset.jpg',
                              width: double.infinity,
                              height: heroHeight,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(_blueOverlayAnimation.value * 1.2), 
                              backgroundBlendMode: BlendMode.overlay,
                            ),
                          ),
                        ),
                        
                        
                        Container(
                          width: double.infinity,
                          height: heroHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3), 
                                Colors.transparent.withOpacity(0.1),
                                Colors.black.withOpacity(0.7), 
                              ],
                              stops: [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                        
                        AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(screenWidth, heroHeight),
                              painter: ParticlesPainter(
                                _particleController.value,
                                isMobile ? 30 : 60,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: CurvedBottomClipper(),
                  child: Container(
                    height: 120, 
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.6), 
                          Colors.white.withOpacity(0.9), 
                          Colors.white,
                        ],
                        stops: [0.0, 0.4, 0.8, 1.0], 
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(
                width: double.infinity,
                height: heroHeight,
                child: Stack(
                  children: [
                    _buildAnimatedDecorations(screenWidth),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : (isTablet ? 40 : 64),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildHeadline(isMobile),
                          const SizedBox(height: 20),
                          
                          const SizedBox(height: 40),
                          _buildSearchBar(isMobile, screenWidth),
                          const SizedBox(height: 24),
                          _buildCategoryFilters(isMobile),
                          const SizedBox(height: 40),
                          
                          _buildSubheading(isMobile),
                          const SizedBox(height: 24),
                          _buildLimitedTimeButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildWaveEffect(),
              ),
            ],
          );
  }

  Widget _buildWaveEffect() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return SizedBox(
          height: 160, 
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                bottom: -10,
                left: -20,
                right: -20,
                child: CustomPaint(
                  painter: WavePainter(
                    _backgroundController.value,
                    color: AppColors.mainBlue.withOpacity(0.12), 
                    heightFactor: 0.5,
                  ),
                  size: const Size(double.infinity, 110), 
                ),
              ),
              
              Positioned(
                bottom: -5,
                left: -20,
                right: -20,
                child: CustomPaint(
                  painter: WavePainter(
                    _backgroundController.value + 0.5,
                    color: AppColors.mainBlue.withOpacity(0.20), 
                    heightFactor: 0.3,
                  ),
                  size: const Size(double.infinity, 90), 
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDecorations(double screenWidth) {
    return Stack(
      children: [
        ...List.generate(8, (index) {
          final random = math.Random(index);
          final size = random.nextDouble() * 10 + 5;
          
          return Positioned(
            top: random.nextDouble() * 500,
            left: random.nextDouble() * screenWidth,
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                final offset = 20 * math.sin(
                  (_particleController.value + index * 0.2) * math.pi * 2
                );
                
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mainBlue.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

 
  Widget _buildHeadline(bool isMobile) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.2, 0.9, curve: Curves.easeOutQuint),
          ),
        ),
        
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Discover Your Next",
                style: GoogleFonts.cormorantGaramond(  
                  fontSize: isMobile ? 42 : 62,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8), 
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                    Shadow(
                      color: Colors.black.withOpacity(0.5), 
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    "Unforgettable ",
                    style: GoogleFonts.cormorantGaramond(  
                      fontSize: isMobile ? 42 : 62,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8), 
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xFF64B5F6),
                          Color(0xFFFFFFFF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      "Experience",
                      style: GoogleFonts.cormorantGaramond(  
                        fontSize: isMobile ? 42 : 62,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8), 
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubheading(bool isMobile) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuint),
          ),
        ),
        
        child: BlurryContainer(
          blur: 5,
          color: Colors.black.withOpacity(0.5), 
          borderRadius: BorderRadius.circular(30),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Text(
            "Explore thousands of activities and destinations in Lebanon",
            style: GoogleFonts.lora(  
              fontSize: isMobile ? 18 : 20, 
              fontWeight: FontWeight.w700, 
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.4,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7), 
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
                Shadow( 
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile, double screenWidth) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _searchBarAnimation,
        child: GestureDetector(
          onTap: widget.onSearchTap,
          child: Container(
            width: isMobile ? double.infinity : screenWidth * 0.5,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.mainBlue.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 12, right: 8),
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.mainBlue,
                        Color(0xFF64B5F6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mainBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _searchBarController,
                    builder: (context, child) {
                      final scale = 0.5 + (0.5 * Curves.elasticOut.transform(_searchBarController.value));
                      return Transform.scale(
                        scale: scale,
                        child: const Icon(Icons.search, color: Colors.white, size: 24),
                      );
                    },
                  ),
                ),
                
                Expanded(
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "What do you want to explore?",
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.lora(  
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: widget.onSearchTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Explore",
                          style: GoogleFonts.lora(  
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryFilters(bool isMobile) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutQuint),
          ),
        ),
        child: Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = isSelected ? -1 : index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? AppColors.mainBlue 
                          : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                              ? AppColors.mainBlue.withOpacity(0.4)
                              : Colors.black.withOpacity(0.1),
                            blurRadius: isSelected ? 12 : 8,
                            spreadRadius: isSelected ? 2 : 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected 
                            ? Colors.transparent 
                            : AppColors.mainBlue.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? Colors.white.withOpacity(0.3) 
                                : AppColors.mainBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(index),
                              color: isSelected ? Colors.white : AppColors.mainBlue,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _categories[index],
                            style: GoogleFonts.lora(  
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
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
    );
  }
  
  IconData _getCategoryIcon(int index) {
    switch(index) {
      case 0: return Icons.terrain;
      case 1: return Icons.water;
      case 2: return Icons.restaurant;
      case 3: return Icons.museum;
      case 4: return Icons.paragliding;
      default: return Icons.category;
    }
  }

  Widget _buildLimitedTimeButton() {
    return Center(
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _contentController,
              curve: const Interval(0.5, 1.0, curve: Curves.easeOutQuint),
            ),
          ),
          child: AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnimation.value),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _scrollToActivities,  
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.mainBlue,
                              Color(0xFF42A5F5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainBlue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.timelapse,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Limited Time Activities",
                              style: GoogleFonts.lora(  
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward,
                                color: AppColors.mainBlue,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: _scrollToActivities,  
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: AppColors.mainBlue.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.mainBlue,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final int particleCount;
  
  ParticlesPainter(this.animationValue, this.particleCount);
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); 
    
    for (int i = 0; i < particleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      
      final opacity = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(animationValue * math.pi * 2 + i));
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double heightFactor;
  
  WavePainter(this.animationValue, {required this.color, this.heightFactor = 1.0});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += size.width / 10) {
      final y = size.height * (1 - heightFactor * math.sin((x / size.width) * math.pi * 4 + animationValue * math.pi * 2) * 0.5);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 50); 
    
    path.quadraticBezierTo(
      size.width / 4, 
      size.height + 10, 
      size.width / 2, 
      size.height + 5  
    );
    
    path.quadraticBezierTo(
      size.width * 3 / 4, 
      size.height, 
      size.width, 
      size.height - 50 
    );
    
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}