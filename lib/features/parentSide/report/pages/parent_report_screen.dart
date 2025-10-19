import 'package:flutter/material.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/common widgets/custom_button.dart';

class ParentReportScreen extends StatefulWidget {
  const ParentReportScreen({super.key});

  @override
  State<ParentReportScreen> createState() => _ParentReportScreenState();
}

class _ParentReportScreenState extends State<ParentReportScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: ParentDrawerShell(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check, color: Colors.black, size: 30),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please describe your issue clearly and provide any relevant details.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check, color: Colors.black, size: 30),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Avoid sharing sensitive information. Our team will review and respond promptly.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: height * 0.24,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: 'Describe your issue...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    fillColor: AppColors.white,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomButton(
                  text: 'Send',
                  borderRadius: BorderRadius.circular(12),
                  width: double.infinity,
                  onTap: () {
                    // TODO: Implement send logic
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report sent!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
