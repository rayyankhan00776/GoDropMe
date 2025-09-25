import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Simple controller for the Driver or Parent option screen.
///
/// Holds local UI state (which option is selected) and exposes navigation
/// helper methods. No backend logic is included — implement that later.
class DopOptionController extends GetxController {
  /// Selected option: 'driver', 'parent', or null when none selected.
  final RxString selected = ''.obs;

  bool get isDriverSelected => selected.value == 'driver';
  bool get isParentSelected => selected.value == 'parent';

  void selectDriver() {
    selected.value = 'driver';
    debugPrint('DopOptionController: driver selected');
  }

  void selectParent() {
    selected.value = 'parent';
    debugPrint('DopOptionController: parent selected');
  }

  void clearSelection() {
    selected.value = '';
    debugPrint('DopOptionController: selection cleared');
  }

  /// Continue action called when the user confirms their selection.
  /// For now this only logs and can navigate later when routes are ready.
  void continueWithSelection() {
    if (selected.value.isEmpty) {
      debugPrint('DopOptionController: no selection yet');
      return;
    }

    // TODO: integrate navigation to the next screen when ready. Keep this
    // offline for now and just log the choice.
    debugPrint('DopOptionController: continuing as ${selected.value}');
  }
}
