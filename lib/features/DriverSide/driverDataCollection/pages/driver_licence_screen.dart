import 'package:flutter/material.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';

class DriverLicenceScreen extends StatelessWidget {
  const DriverLicenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomBlurAppBar(),
      body: Column(children: [Text("Driver Licence Screen")]),
    );
  }
}
