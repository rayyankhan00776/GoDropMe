import 'package:flutter/material.dart';
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
          const SizedBox(height: 6),
          const OptionIllustration(),
          const SizedBox(height: 194),

          OptionActions(
            onContinuePhone: onContinuePhone,
            onContinueGoogle: onContinueGoogle,
          ),

          const SizedBox(height: 5),

          OptionTerms(onTermsTap: onTermsTap, onPrivacyTap: onPrivacyTap),
        ],
      ),
    );
  }
}
