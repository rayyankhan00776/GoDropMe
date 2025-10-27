// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';

class ProfileAvatar extends StatelessWidget {
  final double size;
  const ProfileAvatar({super.key, this.size = 108});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200, // lighter grey fill
          border: Border.all(
            color: Colors.grey.shade400, // grey border
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: size * 0.36,
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
