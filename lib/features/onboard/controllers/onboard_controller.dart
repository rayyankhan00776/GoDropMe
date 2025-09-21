import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:godropme/features/onboard/constants/onboard_constants.dart';

class OnboardController extends GetxController {
  final pageIndex = 0.obs;
  final pageOffset = 0.0.obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 1, keepPage: true)
      ..addListener(() {
        // update continuous offset for animation
        pageOffset.value =
            pageController.hasClients
                ? pageController.page ?? pageController.initialPage.toDouble()
                : 0.0;
      });
  }

  void jumpToPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    pageIndex.value = index;
  }

  void next() {
    final nextPage = (pageIndex.value + 1).clamp(
      0,
      OnboardConstants.pageCount - 1,
    );
    jumpToPage(nextPage);
  }
}
