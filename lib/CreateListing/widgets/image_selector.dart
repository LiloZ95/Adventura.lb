import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelector extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onClearImages;
  final VoidCallback onPickImages;
  final PageController pageController;
  final int currentPage;
  final int maxImages;

  const ImageSelector({
    required this.images,
    required this.onClearImages,
    required this.onPickImages,
    required this.pageController,
    required this.currentPage,
    this.maxImages = 10,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: screenHeight * 0.25,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              images.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            iconSize: 48,
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey[600],
                            onPressed: onPickImages,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Photos',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 16,
                              color:
                                  isDarkMode ? Colors.white : const Color(0xFF1F1F1F),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return Image.file(
                            File(images[index].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          );
                        },
                      ),
                    ),
              if (images.isNotEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: TextButton(
                    onPressed: onClearImages,
                    style: TextButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(
                      "Clear All",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : const Color(0xFF1F1F1F),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Photos: ${images.isEmpty ? 0 : currentPage + 1}/$maxImages - First photo will be shown in the listing\'s thumbnail',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "poppins",
            color: Colors.blue,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
