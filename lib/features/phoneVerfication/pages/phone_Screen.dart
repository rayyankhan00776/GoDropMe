// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/phoneVerfication/widgets/phone_header.dart';
import 'package:godropme/features/phoneVerfication/widgets/phone_input_row.dart';
import 'package:godropme/core/widgets/phone_text_field.dart';
import 'package:godropme/features/phoneVerfication/widgets/phone_actions.dart';
import 'package:godropme/core/utils/responsive.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();
  final String _selectedCode = '+92';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Using centralized validator from PhoneTextField (pakistanPhoneValidator)

  void _onNextPressed() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid) {
      debugPrint('Next tapped');
      // TODO: navigate to OTP screen
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, size: 28),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scaleClamped(context, 16, 12, 24),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              PhoneHeader(),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: PhoneInputRow(
                  controller: _controller,
                  selectedCode: _selectedCode,
                  validator: pakistanPhoneValidator,
                  height: Responsive.scaleClamped(context, 56, 44, 66),
                ),
              ),
              const Spacer(),
              PhoneActions(
                onNext: _onNextPressed,
                height: Responsive.scaleClamped(context, 64, 48, 80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
