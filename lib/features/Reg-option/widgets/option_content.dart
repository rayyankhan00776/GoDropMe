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
    // layout is delegated to child widgets. Use Expanded on the illustration
    // area so actions remain anchored to the bottom and the column won't
    // overflow on short screens.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const OptionHeader(),
          SizedBox(height: Responsive.scaleClamped(context, 6, 6, 14)),

          // Give the illustration and title area flexible space so it can
          // shrink on small screens and grow on larger ones.
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                // Scroll only if the illustration area overflows slightly on
                // extremely small devices; otherwise it's static. Use
                // physics: NeverScrollableScrollPhysics to keep behavior static
                // on most devices, but allow minimal scroll as a safety net.
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [const OptionIllustration()],
                ),
              ),
            ),
          ),

          // Actions and terms remain outside the Expanded so they stay
          // anchored near the bottom.
          OptionActions(
            onContinuePhone: onContinuePhone,
            onContinueGoogle: onContinueGoogle,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 5, 4, 12)),

          OptionTerms(onTermsTap: onTermsTap, onPrivacyTap: onPrivacyTap),

          // Respect device safe area at the bottom.
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
        ],
      ),
    );
  }
}
