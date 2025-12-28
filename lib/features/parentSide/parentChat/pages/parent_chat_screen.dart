// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/common_widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/parentChat/controllers/parent_chat_controller.dart';
import 'package:godropme/features/parentSide/parentChat/models/chat_contact.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/routes.dart';

class ParentChatScreen extends StatelessWidget {
  const ParentChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ParentChatController>();
    return ParentDrawerShell(
      body: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Messages',
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    // Refresh button
                    Obx(() => ctrl.isLoading.value
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : IconButton(
                            onPressed: ctrl.refresh,
                            icon: Icon(
                              Icons.refresh_rounded,
                              color: AppColors.darkGray,
                            ),
                          )),
                  ],
                ),
              ),

              // Chat list
              Expanded(
                child: Obx(() {
                  // Error state
                  if (ctrl.errorMessage.isNotEmpty && ctrl.contacts.isEmpty) {
                    return _buildErrorState(ctrl);
                  }

                  // Empty state
                  if (ctrl.contacts.isEmpty && !ctrl.isLoading.value) {
                    return _buildEmptyState();
                  }

                  // Chat list
                  return RefreshIndicator(
                    onRefresh: ctrl.refresh,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: ctrl.contacts.length,
                      itemBuilder: (context, index) {
                        final contact = ctrl.contacts[index];
                        return _ChatListTile(
                          contact: contact,
                          onTap: () => Get.toNamed(
                            AppRoutes.parentConversation,
                            arguments: {
                              'contactId': contact.id,
                              'name': contact.name,
                              'avatarUrl': contact.avatarUrl,
                            },
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: AppTypography.optionLineSecondary.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start a conversation with your driver from the Active Services section',
              textAlign: TextAlign.center,
              style: AppTypography.helperSmall.copyWith(
                color: AppColors.darkGray.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ParentChatController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.accent.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTypography.optionLineSecondary.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ctrl.errorMessage.value,
            textAlign: TextAlign.center,
            style: AppTypography.helperSmall.copyWith(
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: ctrl.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat list tile with avatar, name, last message, time, and unread badge
class _ChatListTile extends StatelessWidget {
  final ParentChatContact contact;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: contact.unreadCount > 0
              ? AppColors.primary.withOpacity(0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Avatar
            _ContactAvatar(
              name: contact.name,
              avatarUrl: contact.avatarUrl,
              hasUnread: contact.unreadCount > 0,
            ),
            const SizedBox(width: 14),
            // Name and last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.name,
                          style: AppTypography.optionLineSecondary.copyWith(
                            fontSize: 16,
                            fontWeight: contact.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Time
                      if (contact.lastMessageAt != null)
                        Text(
                          _formatTime(contact.lastMessageAt!),
                          style: AppTypography.helperSmall.copyWith(
                            color: contact.unreadCount > 0
                                ? AppColors.primary
                                : AppColors.darkGray,
                            fontWeight: contact.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.lastMessage ?? 'No messages yet',
                          style: AppTypography.helperSmall.copyWith(
                            color: contact.unreadCount > 0
                                ? AppColors.black.withOpacity(0.8)
                                : AppColors.darkGray,
                            fontWeight: contact.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Unread badge
                      if (contact.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            contact.unreadCount > 99
                                ? '99+'
                                : contact.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      // Today - show time
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      // Within a week - show day name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    } else {
      // Older - show date
      return '${time.day}/${time.month}/${time.year % 100}';
    }
  }
}

/// Contact avatar with online indicator
class _ContactAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool hasUnread;

  const _ContactAvatar({
    required this.name,
    this.avatarUrl,
    this.hasUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? 'D'
        : name
            .trim()
            .split(RegExp(r"\s+"))
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();

    Widget avatarContent;

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarContent = AppwriteImage(
        imageUrl: avatarUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(28),
        placeholder: _buildInitialsAvatar(initials),
        errorWidget: _buildInitialsAvatar(initials),
      );
    } else {
      avatarContent = _buildInitialsAvatar(initials);
    }

    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: hasUnread
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: ClipOval(child: avatarContent),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}
