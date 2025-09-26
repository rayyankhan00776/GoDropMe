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
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // Ensure binding is initialized (safe if already added to routes)
    DriverNameBinding().dependencies();

    // When the user has already submitted and there is an error, we want to
    // update the spacing as they type so the error area can disappear and
    // spacing shrink without needing another button press.
    _textController.addListener(() {
      if (_submitted) setState(() {});
    });
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
                child: DrivernameInput(
                  controller: _textController,
                  showError: _submitted,
                ),
              ),

              // Compute whether the driver name input currently has an error
              // that should be shown (only after user pressed Next).
              Builder(
                builder: (context) {
                  String? validator(String? v) => v == null || v.trim().isEmpty
                      ? 'Please enter full name'
                      : null;
                  final String? errorText = _submitted
                      ? validator(_textController.text)
                      : null;
                  final double gap = errorText != null ? 27.0 : 10.0;

                  return Column(
                    children: [
                      SizedBox(height: gap),

                      DrivernameAction(
                        onNext: () async {
                          setState(() => _submitted = true);
                          final valid =
                              _formKey.currentState?.validate() ?? false;
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
