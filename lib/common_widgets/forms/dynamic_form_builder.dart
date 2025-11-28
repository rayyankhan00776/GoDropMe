import 'package:flutter/material.dart';
import 'form_items.dart';

class DynamicFormBuilder extends StatelessWidget {
  final List<FormItem> items;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  const DynamicFormBuilder({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [for (final item in items) item.build(context)],
      ),
    );
  }
}
