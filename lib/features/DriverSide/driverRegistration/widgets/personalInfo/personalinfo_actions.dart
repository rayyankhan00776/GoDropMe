import 'package:flutter/material.dart';
import 'package:godropme/common_widgets/progress_next_bar.dart';

/// Simple wrapper to keep the PersonalInfoScreen smaller.
class PersonalinfoActions extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const PersonalinfoActions({
    super.key,
    this.currentStep = 1,
    this.totalSteps = 4,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return ProgressNextBar(
      currentStep: currentStep,
      totalSteps: totalSteps,
      onNext: onNext,
      onPrevious: onPrevious,
    );
  }
}
