import 'package:flutter/material.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/common_widgets/custom_button.dart';

/// A themed dialog for parents to rate and review their driver.
/// 
/// Shows after 1 month of service to collect feedback about the driver.
/// Matches the app's purple gradient theme with star rating and optional review text.
class DriverReviewDialog extends StatefulWidget {
  /// Driver's name to display in the dialog
  final String driverName;
  
  /// Driver's profile photo URL (optional)
  final String? driverPhotoUrl;
  
  /// Callback when review is submitted
  /// Returns the rating (1-5) and optional review text
  final void Function(int rating, String? review)? onSubmit;
  
  /// Callback when dialog is dismissed without review
  final VoidCallback? onSkip;

  const DriverReviewDialog({
    super.key,
    required this.driverName,
    this.driverPhotoUrl,
    this.onSubmit,
    this.onSkip,
  });

  /// Shows the review dialog and returns true if review was submitted
  static Future<bool> show({
    required BuildContext context,
    required String driverName,
    String? driverPhotoUrl,
    void Function(int rating, String? review)? onSubmit,
    VoidCallback? onSkip,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DriverReviewDialog(
        driverName: driverName,
        driverPhotoUrl: driverPhotoUrl,
        onSubmit: onSubmit,
        onSkip: onSkip,
      ),
    );
    return result ?? false;
  }

  @override
  State<DriverReviewDialog> createState() => _DriverReviewDialogState();
}

class _DriverReviewDialogState extends State<DriverReviewDialog> {
  int _selectedRating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a rating'),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    final reviewText = _reviewController.text.trim();
    widget.onSubmit?.call(
      _selectedRating,
      reviewText.isNotEmpty ? reviewText : null,
    );
    
    Navigator.of(context).pop(true);
  }

  void _handleSkip() {
    widget.onSkip?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewInsets.top + 50,
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              _buildHeader(),
              
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'How was your experience?',
                      style: AppTypography.optionHeading.copyWith(
                        fontSize: 20,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rate your service with ${widget.driverName}',
                      style: AppTypography.onboardSubtitle.copyWith(
                        fontSize: 14,
                        color: AppColors.gray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Star Rating
                    _buildStarRating(),
                    const SizedBox(height: 8),
                    
                    // Rating Label
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _getRatingLabel(),
                        key: ValueKey(_selectedRating),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _selectedRating > 0 
                              ? AppColors.primary 
                              : AppColors.lightGray,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Review Text Field
                    _buildReviewField(),
                    const SizedBox(height: 24),
                    
                    // Buttons
                    _buildButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Driver Photo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: AppColors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: widget.driverPhotoUrl != null && widget.driverPhotoUrl!.isNotEmpty
                  ? AppwriteImage(
                      imageUrl: widget.driverPhotoUrl!,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      placeholder: Container(
                        color: AppColors.grayLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.driverName,
            style: AppTypography.onboardButton.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '1 Month of Service 🎉',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.person,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= _selectedRating;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedRating = starIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 44,
                color: isSelected ? AppColors.warning : AppColors.lightGray,
              ),
            ),
          ),
        );
      }),
    );
  }

  String _getRatingLabel() {
    switch (_selectedRating) {
      case 1:
        return 'Poor 😞';
      case 2:
        return 'Fair 😐';
      case 3:
        return 'Good 🙂';
      case 4:
        return 'Very Good 😊';
      case 5:
        return 'Excellent! 🌟';
      default:
        return 'Tap a star to rate';
    }
  }

  Widget _buildReviewField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
      ),
      child: TextField(
        controller: _reviewController,
        maxLines: 3,
        maxLength: 500,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Share your experience (optional)',
          hintStyle: TextStyle(
            color: AppColors.gray.withOpacity(0.6),
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          counterStyle: TextStyle(
            color: AppColors.gray.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Submit Button
        CustomButton(
          text: _isSubmitting ? 'Submitting...' : 'Submit Review',
          onTap: _isSubmitting ? null : _handleSubmit,
          height: 52,
        ),
        const SizedBox(height: 12),
        // Skip Button
        TextButton(
          onPressed: _handleSkip,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Maybe Later',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
        ),
      ],
    );
  }
}
