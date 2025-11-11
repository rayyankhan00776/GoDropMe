import 'package:flutter/material.dart';

class LocationSearchPanel extends StatelessWidget {
  final String title;
  final String addressText;
  final VoidCallback onCopy;
  const LocationSearchPanel({
    super.key,
    required this.title,
    required this.addressText,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    addressText,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onCopy,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.copy, size: 16, color: Colors.black45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
