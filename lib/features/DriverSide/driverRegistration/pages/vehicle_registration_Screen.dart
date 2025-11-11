// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:godropme/common%20widgets/custom_Appbar.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/vehicleRegistration/vehicle_registration_content.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomBlurAppBar(),
      body: VehicleRegistrationContent(),
    );
  }
}
