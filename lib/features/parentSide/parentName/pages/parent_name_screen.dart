import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/parentName/controller/parent_name_controller.dart';
import 'package:godropme/features/parentSide/parentName/widgets/parentName_action.dart';
import 'package:godropme/features/parentSide/parentName/widgets/parentName_header.dart';
import 'package:godropme/features/parentSide/parentName/widgets/parentName_input.dart';

// binding is provided via route configuration; do not register it here.

class ParentNameScreen extends StatefulWidget {
  const ParentNameScreen({super.key});

  @override
  State<ParentNameScreen> createState() => _ParentNameScreenState();
}

class _ParentNameScreenState extends State<ParentNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // Binding is provided by the route; avoid registering dependencies here.

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
              ParentnameHeader(),
              SizedBox(height: Responsive.scaleClamped(context, 30, 18, 40)),

              Form(
                key: _formKey,
                child: ParentnameInput(
                  controller: _textController,
                  showError: _submitted,
                ),
              ),

              // Compute whether the parent name input currently has an error
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
                      SizedBox(
                        height: Responsive.scaleClamped(context, gap, 8, 40),
                      ),

                      ParentnameAction(
                        onNext: () async {
                          setState(() => _submitted = true);
                          final valid =
                              _formKey.currentState?.validate() ?? false;
                          if (!valid) return;

                          final c = Get.find<ParentNameController>();
                          c.setName(_textController.text.trim());
                          await c.saveName();
                          // For now just go back once saved
                          Get.offNamed(AppRoutes.parentHomeScreen);
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
