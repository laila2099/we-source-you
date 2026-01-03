import 'package:flutter/material.dart';
// Assuming you are using screen_util based on your .h and .r usage
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        // 1. Show a loading indicator (optional but recommended)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // 2. Call the logic
        final userCredential = await AuthController().signInWithGoogle();

        // 3. Remove loading indicator
        Navigator.of(context).pop();

        // 4. Handle navigation based on result
        if (userCredential != null) {
          // Success: Navigate to Home Screen
          // Navigator.pushReplacementNamed(context, '/home');
          print("Signed in as: ${userCredential.user?.displayName}");
        } else {
          // Failure or Cancelled: Show text
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign in failed or cancelled')),
          );
        }
      },
      // Use the FontAwesome Google icon for a professional look
      icon: Text('G', style: AppTextStyles.bodyBold(context)),

      label: Text(
        'Continue with Google',
        style: AppTextStyles.body(context), // Your custom style
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 50.h),
        backgroundColor: Colors.white, // Standard Google button background
        foregroundColor: Colors.black, // Text color
        side: const BorderSide(color: Colors.grey), // Google standard border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      ),
    );
  }
}
