import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer_shell.dart';
import 'package:godropme/features/driverSide/driverChat/controllers/driver_chat_controller.dart';
import 'package:godropme/features/driverSide/common widgets/drawer widgets/driver_drawer_card.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/routes.dart';

class DriverChatScreen extends StatelessWidget {
  const DriverChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DriverChatController());
    return Scaffold(
      body: DriverDrawerShell(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text('Chats', style: AppTypography.titleLarge),
                ),
                Expanded(
                  child: Obx(
                    () => ListView.separated(
                      itemCount: ctrl.contacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final c = ctrl.contacts[index];
                        return DriverDrawerCard(
                          child: ListTile(
                            leading: CircleAvatar(child: Text(c.name[0])),
                            title: Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                            ),
                            onTap: () => Get.toNamed(
                              AppRoutes.driverConversation,
                              arguments: {'contactId': c.id, 'name': c.name},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
