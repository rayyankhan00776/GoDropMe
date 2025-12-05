import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/common_widgets/custom_button.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

/// Screen shown to drivers after completing registration.
/// Informs them that their application is under review (12-24 hours).
/// After admin approval/rejection, driver will be notified via push/email.
class DriverPendingApprovalScreen extends StatelessWidget {
  const DriverPendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scaleClamped(context, 24, 16, 32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Illustration - hourglass/review icon
              Container(
                width: Responsive.scaleClamped(context, 140, 100, 180),
                height: Responsive.scaleClamped(context, 140, 100, 180),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: Responsive.scaleClamped(context, 72, 52, 92),
                  color: AppColors.primary,
                ),
              ),

              SizedBox(height: Responsive.scaleClamped(context, 40, 24, 56)),

              // Title
              Text(
                'Application Under Review',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),

              // Subtitle with time estimate
              Text(
                'Thank you for registering as a driver!\n\n'
                'Our team is reviewing your application. '
                'This usually takes 12-24 hours.',
                style: AppTypography.onboardSubtitle.copyWith(
                  color: AppColors.darkGray,
                  height: 1.5,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Responsive.scaleClamped(context, 32, 20, 44)),

              // Info card with notification info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.lightGreen,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will receive a notification and email once your application is approved or if we need more information.',
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.darkGray,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

             // Logout button
              CustomButton(
                text: 'Sign Out',
                onTap: () async {
                  // Logout from Appwrite (delete session)
                  await AuthService.instance.logout();
                  debugPrint('✅ Logged out from Appwrite');

                  // Clear all local data
                  await LocalStorage.clearAllUserData();
                  debugPrint('✅ Local data cleared');

                  // Navigate to option screen
                  Get.offAllNamed(AppRoutes.optionScreen);
                },
                height: Responsive.scaleClamped(context, 56, 48, 64),
                width: double.infinity,
                borderRadius: BorderRadius.circular(12),
                textColor: Colors.white,
              ),

              SizedBox(height: Responsive.scaleClamped(context, 24, 16, 32)),
            ],
          ),
        ),
      ),
    );
  }
}
