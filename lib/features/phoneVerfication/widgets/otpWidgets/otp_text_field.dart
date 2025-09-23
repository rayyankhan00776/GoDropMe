import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_typography.dart';

class OtpTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool autoFocus;
  final int fieldNumber;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  // No longer support raw key events here to avoid Focus reparenting issues.
  // Use onChanged to handle navigation between fields.

  const OtpTextField({
    super.key,
    required this.controller,
    this.autoFocus = false,
    this.fieldNumber = 0,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  // Removed raw key handling to avoid FocusNode reparenting errors.

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Focus(
        focusNode: _focusNode,
        onKey: (node, event) {
          // Only handle key down events
          if (event is RawKeyDownEvent) {
            // Handle backspace: if this field is already empty, move focus to previous
            if (event.logicalKey == LogicalKeyboardKey.backspace) {
              if (widget.controller.text.isEmpty) {
                FocusScope.of(context).previousFocus();
                return KeyEventResult.handled;
              }
            }
          }
          return KeyEventResult.ignored;
        },
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autoFocus,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          style: AppTypography.onboardTitle.copyWith(fontSize: 22),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.lightGray, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (value) {
            widget.onChanged?.call(value);
            // If user entered a character, move to next field
            if (_previousText.isEmpty && value.isNotEmpty) {
              FocusScope.of(context).nextFocus();
            }
            // If user deleted (previous had a char and now empty), move to previous
            if (_previousText.isNotEmpty && value.isEmpty) {
              FocusScope.of(context).previousFocus();
            }
            _previousText = value;
          },
        ),
      ),
    );
  }
}
