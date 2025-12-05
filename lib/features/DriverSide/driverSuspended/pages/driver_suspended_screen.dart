import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common_widgets/custom_button.dart';

/// Screen shown to drivers whose account has been suspended.
/// Displays suspension reason and contact info for support.
class DriverSuspendedScreen extends StatelessWidget {
  const DriverSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get suspension reason from route arguments if provided
    final args = Get.arguments as Map<String, dynamic>?;
    final reason =
        args?['reason'] as String? ??
        'No specific reason provided.';

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

              // Warning icon
              Container(
                width: Responsive.scaleClamped(context, 140, 100, 180),
                height: Responsive.scaleClamped(context, 140, 100, 180),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block_rounded,
                  size: Responsive.scaleClamped(context, 72, 52, 92),
                  color: AppColors.accent,
                ),
              ),

              SizedBox(height: Responsive.scaleClamped(context, 40, 24, 56)),

              // Title
              Text(
                'Account Suspended',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),

              // Reason
              Text(
                "Your account has been temporarily suspended.",
                style: AppTypography.onboardSubtitle.copyWith(
                  color: AppColors.darkGray,
                  height: 1.5,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

               SizedBox(height: Responsive.scaleClamped(context, 24, 16, 32)),

              // Reason card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reason',
                          style: AppTypography.helperSmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        reason,
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.darkGray,
                          height: 1.4,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.scaleClamped(context, 24, 16, 32)),

              // Info card with contact support
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.support_agent_outlined,
                      color: AppColors.warning,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'If you believe this is a mistake or need assistance, please contact our support team.',
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.darkGray,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.scaleClamped(context, 16, 12, 20)),

              // Contact support button (outlined)
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Open email client or support chat
                  // For now, just show a snackbar
                  Get.snackbar(
                    'Contact Support',
                    'Email us at support@godropme.com',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary.withOpacity(0.9),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
                icon: const Icon(Icons.email_outlined),
                label: const Text('Contact Support'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
