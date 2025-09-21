import 'package:flutter/material.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'components/option_header.dart';
import 'components/option_illustration.dart';
import 'components/option_actions.dart';
import 'components/option_terms.dart';

class OptionContent extends StatelessWidget {
  final VoidCallback? onContinuePhone;
  final VoidCallback? onContinueGoogle;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  const OptionContent({
    this.onContinuePhone,
    this.onContinueGoogle,
    this.onTermsTap,
    this.onPrivacyTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // layout is delegated to child widgets
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const OptionHeader(),
          SizedBox(height: Responsive.scaleClamped(context, 6, 6, 14)),
          const OptionIllustration(),
          SizedBox(height: Responsive.scaleClamped(context, 194, 120, 260)),

          OptionActions(
            onContinuePhone: onContinuePhone,
            onContinueGoogle: onContinueGoogle,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 5, 4, 12)),

          OptionTerms(onTermsTap: onTermsTap, onPrivacyTap: onPrivacyTap),
        ],
      ),
    );
  }
}
