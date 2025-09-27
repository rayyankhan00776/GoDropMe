import 'package:flutter/material.dart';

/// A small reusable image container used across the app.
///
/// - [imagePath] : optional asset image path to display. If null, a placeholder
///   with an add icon is shown.
/// - [onTap] : tapped callback when user taps the container.
/// - [width], [height] : size of the container (defaults to 120x120).
class CustomImageContainer extends StatelessWidget {
  final String? imagePath;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const CustomImageContainer({
    super.key,
    this.imagePath,
    this.onTap,
    this.width = 120,
    this.height = 120,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(7),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: borderRadius ?? BorderRadius.circular(7),
          image: imagePath != null
              ? DecorationImage(
                  image: AssetImage(imagePath!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imagePath == null
            ? IconButton(
                onPressed: onTap,
                icon: Icon(Icons.add, color: Colors.black54),
              )
            : null,
      ),
    );
  }
}
