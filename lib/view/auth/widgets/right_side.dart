import 'package:flutter/material.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/view/auth/widgets/check_list.dart';

class WelcomePanel extends StatelessWidget {
  const WelcomePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        gradient: const LinearGradient(
          colors: [AppColors.lightBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          // Main Welcome Header
          Text(
            'Join the Global\nMedia Community',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),

          // Subheader
          Text(
            'Connect with talented professionals and discover amazing opportunities',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          SizedBox(height: 40),

          // List of features
          CheckListItem(text: 'Access to thousands of media professionals'),
          CheckListItem(text: 'Verified profiles and quality assurance'),
          CheckListItem(text: 'Secure payment and project management'),
          CheckListItem(text: '24/7 customer support'),
        ],
      ),
    );
  }
}
