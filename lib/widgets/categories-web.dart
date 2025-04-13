import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';

class CategoriesWebWidget extends StatefulWidget {
  const CategoriesWebWidget({Key? key}) : super(key: key);

  @override
  _CategoriesWebWidgetState createState() => _CategoriesWebWidgetState();
}

class _CategoriesWebWidgetState extends State<CategoriesWebWidget> {
  int _hoveredIndex = -1;
  int _currentPage = 0;
  late final PageController _pageController;
  Timer? _autoScrollTimer;

  final List<Map<String, dynamic>> categories = [
    {
      'image': 'paragliding.webp',
      'title': 'Paragliding',
      'description':
          'Soar above the stunning bay of Jounieh and enjoy breath-taking aerial views of the Lebanese coast.',
      'locations': 9,
      'rating': 4.8,
    },
    {
      'image': 'jetski.jpeg',
      'title': 'Jetski Rentals',
      'description':
          'Experience the thrill of jetskiing along Lebanon shores, available at various coastal locations.',
      'locations': 2,
      'rating': 4.6,
    },
    {
      'image': 'island.jpg',
      'title': 'Island Trips',
      'description':
          'Explore Lebanon coastline with private boat rentals, island hopping, and unforgettable sea adventures.',
      'locations': 5,
      'rating': 4.7,
    },
    {
      'image': 'picnic.webp',
      'title': 'Picnic Spots',
      'description':
          'Relax and unwind at scenic picnic spots, options available for a perfect day out.',
      'locations': 5,
      'rating': 4.5,
    },
    {
      'image': 'cars.webp',
      'title': 'Car Events',
      'description':
          'Join Lebanon car enthusiasts at exciting car meets and events.',
      'locations': 5,
      'rating': 4.3,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController(initialPage: 0, viewportFraction: 0.3);

    
    _startAutoScroll();

    
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < categories.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  
  void _pauseAutoScroll() {
    _stopAutoScroll();
  }

  
  void _resumeAutoScroll() {
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1200;

    
    final double sideSpacing = isMobile ? 16 : (isTablet ? 48 : 96);

    
    final double cardHeight = isMobile ? 320.0 : 360.0;

    
    final double contentPadding = isMobile ? 16 : (isTablet ? 32 : 64);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: contentPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.mainBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Popular Categories",
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Discover our most popular adventure categories across Lebanon",
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color: AppColors.mainBlue.withOpacity(0.5), width: 1),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "See all",
                        style: TextStyle(
                          color: AppColors.mainBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward,
                          size: 16, color: AppColors.mainBlue),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          
          Stack(
            alignment: Alignment.center,
            children: [
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sideSpacing),
                child: SizedBox(
                  height: cardHeight + 40, 
                  width: double.infinity,
                  child: GestureDetector(
                    onPanDown: (_) => _pauseAutoScroll(),
                    onPanEnd: (_) => _resumeAutoScroll(),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: categories.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final bool isCurrentPage = _currentPage == index;

                        return MouseRegion(
                          onEnter: (_) => setState(() => _hoveredIndex = index),
                          onExit: (_) => setState(() => _hoveredIndex = -1),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: isCurrentPage ? 0 : 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: isCurrentPage
                                      ? Colors.black.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: isCurrentPage ? 20 : 10,
                                  offset: isCurrentPage
                                      ? Offset(0, 10)
                                      : Offset(0, 5),
                                ),
                              ],
                              
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  
                                  Stack(
                                    children: [
                                      Image.asset(
                                        'assets/Pictures/${category['image']}',
                                        height: isMobile ? 140 : 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.3),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                category['rating'].toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(isMobile ? 16 : 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category['title'],
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            category['description'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                              fontFamily: 'Poppins',
                                              height: 1.4,
                                            ),
                                          ),
                                          Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.mainBlue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.place,
                                                      color: AppColors.mainBlue,
                                                      size: 14,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "${category['locations']} locations",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            AppColors.mainBlue,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              _hoveredIndex == index ||
                                                      isCurrentPage
                                                  ? ElevatedButton(
                                                      onPressed: () {},
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            AppColors.mainBlue,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 16,
                                                                vertical: 8),
                                                        elevation: 0,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            "Explore",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          SizedBox(width: 4),
                                                          Icon(
                                                              Icons
                                                                  .arrow_forward,
                                                              size: 14,
                                                              color:
                                                                  Colors.white),
                                                        ],
                                                      ),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              
              if (!isMobile)
                Positioned(
                  left: 24,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (_currentPage > 0) {
                          _pageController.animateToPage(
                            _currentPage - 1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _pageController.animateToPage(
                            categories.length - 1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      icon: Icon(Icons.arrow_back_ios_new, size: 18),
                      color: AppColors.mainBlue,
                    ),
                  ),
                ),

              if (!isMobile)
                Positioned(
                  right: 24,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (_currentPage < categories.length - 1) {
                          _pageController.animateToPage(
                            _currentPage + 1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _pageController.animateToPage(
                            0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      icon: Icon(Icons.arrow_forward_ios, size: 18),
                      color: AppColors.mainBlue,
                    ),
                  ),
                ),
            ],
          ),

          
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              categories.length,
              (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: _currentPage == index ? 24 : 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentPage == index
                        ? AppColors.mainBlue
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
