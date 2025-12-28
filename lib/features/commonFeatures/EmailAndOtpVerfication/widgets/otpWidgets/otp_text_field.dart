import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class OtpTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool autoFocus;
  final int fieldNumber;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final double size;
  final VoidCallback? onBackspaceEmpty;
  final ValueChanged<String>? onPaste;

  const OtpTextField({
    super.key,
    required this.controller,
    this.autoFocus = false,
    this.fieldNumber = 0,
    this.focusNode,
    this.onChanged,
    this.size = 64,
    this.onBackspaceEmpty,
    this.onPaste,
  });

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;

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

  @override
  Widget build(BuildContext context) {
    final boxSize = widget.size;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: KeyboardListener(
        focusNode: FocusNode(), // Separate focus node for keyboard listener
        onKeyEvent: (event) {
          // Handle backspace on empty field
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              widget.controller.text.isEmpty) {
            widget.onBackspaceEmpty?.call();
          }
        },
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autoFocus,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          maxLength: 6, // Allow up to 6 for paste support
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          style: AppTypography.onboardTitle.copyWith(
            fontSize: (boxSize * 0.39).clamp(14.0, 26.0),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            counterText: "",
            contentPadding: EdgeInsets.zero,
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
            // Handle paste of multiple digits
            if (value.length > 1) {
              // Keep only the first digit in this field
              final firstDigit = value[0];
              widget.controller.text = firstDigit;
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: 1),
              );
              widget.onChanged?.call(firstDigit);
              // Pass all pasted digits to be distributed across fields
              widget.onPaste?.call(value);
              return;
            }

            widget.onChanged?.call(value);
          },
        ),
      ),
    );
  }
}
