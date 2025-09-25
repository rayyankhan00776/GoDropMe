import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/driverName/driverName_action.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/driverName/driverName_header.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/driverName/driverName_input.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/controllers/driver_name_controller.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/binding/driver_name_binding.dart';

class DriverNameScreen extends StatefulWidget {
  const DriverNameScreen({super.key});

  @override
  State<DriverNameScreen> createState() => _DriverNameScreenState();
}

class _DriverNameScreenState extends State<DriverNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure binding is initialized (safe if already added to routes)
    DriverNameBinding().dependencies();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrivernameHeader(),
              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: DrivernameInput(controller: _textController),
              ),

              const SizedBox(height: 24),

              DrivernameAction(
                onNext: () async {
                  final valid = _formKey.currentState?.validate() ?? false;
                  if (!valid) return;

                  final c = Get.find<DriverNameController>();
                  c.setName(_textController.text.trim());
                  await c.saveName();
                  // For now just go back once saved
                  Get.back();
                },
                height: Responsive.scaleClamped(context, 64, 48, 80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
