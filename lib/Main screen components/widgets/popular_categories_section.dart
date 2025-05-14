import 'package:flutter/material.dart';
import 'package:adventura/event_cards/Cards.dart';

class PopularCategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final double screenWidth;
  final double screenHeight;
  final bool isDarkMode;
  final void Function(String categoryName) onCategorySelected;

  const PopularCategoriesSection({
    Key? key,
    required this.categories,
    required this.screenWidth,
    required this.screenHeight,
    required this.isDarkMode,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Popular Categories",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenHeight * 0.27,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: Row(
                children: categories.map((category) {
                  final Map<String, String> imageMap = {
                    "Paragliding": "paragliding.webp",
                    "Jetski Rentals": "jetski.jpeg",
                    "Island Trips": "island.jpg",
                    "Picnic Spots": "picnic.webp",
                    "Car Events": "cars.webp",
                  };

                  final Map<String, double> alignMap = {
                    "Paragliding": 0.0,
                    "Jetski Rentals": 0.8,
                    "Island Trips": 0.0,
                    "Picnic Spots": 0.0,
                    "Car Events": 1.0,
                  };

                  final Map<String, String> searchCategoryMap = {
                    "Paragliding": "Paragliding",
                    "Jetski Rentals": "Jetski",
                    "Island Trips": "Sea Trips",
                    "Picnic Spots": "Picnic",
                    "Car Events": "Car Events",
                  };

                  final name = category['name'];
                  final image = imageMap[name] ?? '__fallback__';
                  final align = alignMap[name] ?? 0.0;
                  final searchName = searchCategoryMap[name] ?? name;

                  return GestureDetector(
                      onTap: () => onCategorySelected(searchName),
                      child: CategoryCard(
                        key: ValueKey(
                            name), // 👈 helps Flutter track widget identity
                        imagePath: image,
                        categoryName: name,
                        description: '',
                        listings: int.tryParse(
                                category['activity_count'].toString()) ??
                            0,
                        align: align,
                      ));
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
