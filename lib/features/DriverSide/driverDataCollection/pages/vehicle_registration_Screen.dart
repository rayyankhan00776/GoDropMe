// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';

class VehicleRegistrationScreen extends StatelessWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const CustomBlurAppBar());
  }
}
