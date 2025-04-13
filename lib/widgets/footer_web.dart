// footer_widget.dart
import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: isMobile ? 20 : 60,
      ),
      child: Column(
        children: [
          // Divider
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 30),
          
          // Footer content
          isMobile 
            ? _buildMobileFooter() 
            : _buildDesktopFooter(isTablet),
            
          const SizedBox(height: 30),
          
          // Copyright text
          Text(
            '© ${DateTime.now().year} Adventura. All rights reserved.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterSection(
          title: 'Adventura',
          items: ['About Us', 'Careers', 'Blog', 'Press'],
        ),
        SizedBox(height: 30),
        _buildFooterSection(
          title: 'Support',
          items: ['Help Center', 'Contact Us', 'Safety', 'COVID-19 Resources'],
        ),
        SizedBox(height: 30),
        _buildFooterSection(
          title: 'Legal',
          items: ['Terms of Service', 'Privacy Policy', 'Cookie Policy'],
        ),
        SizedBox(height: 30),
        _buildSocialMediaSection(),
      ],
    );
  }

  Widget _buildDesktopFooter(bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isTablet ? 4 : 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Image.asset(
            'assets/images/MainLogo.png',
            width: 200,
            height: 120,
            fit: BoxFit.cover,
          ),
              SizedBox(height: 20),
              Text(
                'Discover extraordinary experiences and activities around you. Adventure awaits!',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20),
              _buildSocialMediaSection(),
            ],
          ),
        ),
        SizedBox(width: 40),
        Expanded(
          flex: 2,
          child: _buildFooterSection(
            title: 'Adventura',
            items: ['About Us', 'Careers', 'Blog', 'Press'],
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: _buildFooterSection(
            title: 'Support',
            items: ['Help Center', 'Contact Us', 'Safety', 'COVID-19 Resources'],
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: _buildFooterSection(
            title: 'Legal',
            items: ['Terms of Service', 'Privacy Policy', 'Cookie Policy'],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection({required String title, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {},
            child: Text(
              item,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow Us',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            _socialIcon('assets/Icons/facebook.png'),
            SizedBox(width: 16),
            _socialIcon('assets/Icons/facebook.png'),
            SizedBox(width: 16),
            _socialIcon('assets/Icons/facebook.png'),
            SizedBox(width: 16),
            _socialIcon('assets/Icons/facebook.png'),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(String assetPath) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            assetPath,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }
}
