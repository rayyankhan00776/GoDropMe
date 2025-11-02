import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverChat/controllers/driver_conversation_controller.dart';
import 'package:godropme/theme/colors.dart';

class DriverConversationScreen extends StatefulWidget {
  const DriverConversationScreen({super.key});

  @override
  State<DriverConversationScreen> createState() =>
      _DriverConversationScreenState();
}

class _DriverConversationScreenState extends State<DriverConversationScreen> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverConversationController>();
    final name = (Get.arguments is Map)
        ? (Get.arguments as Map)['name']?.toString() ?? 'Chat'
        : 'Chat';
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                reverse: true,
                itemCount: ctrl.messages.length,
                itemBuilder: (context, index) {
                  final msg = ctrl.messages[ctrl.messages.length - 1 - index];
                  final align = msg.fromMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft;
                  final bg = msg.fromMe
                      ? AppColors.primary
                      : const Color(0xFFF1F2F6);
                  final fg = msg.fromMe ? AppColors.white : AppColors.black;
                  return Align(
                    alignment: align,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text, style: TextStyle(color: fg)),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        final text = _input.text;
                        _input.clear();
                        ctrl.send(text);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.send, color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
