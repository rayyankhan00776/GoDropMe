import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/common_widgets/forms/dynamic_form_builder.dart';
import 'package:godropme/common_widgets/forms/form_items.dart';
import 'package:godropme/common_widgets/custom_phone_text_field.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/utils/validators_extra.dart';
import 'package:godropme/utils/validators.dart';

// Date input formatting now provided via ExtraInputFormatters.dateDmy

class DriverLicenceForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController licenceNumberController;
  final TextEditingController expiryDateController;
  final bool showSubmittedErrors;
  final bool showGlobalError;

  const DriverLicenceForm({
    super.key,
    required this.formKey,
    required this.licenceNumberController,
    required this.expiryDateController,
    required this.showSubmittedErrors,
    this.showGlobalError = false,
  });

  List<FormItem> _buildItems(BuildContext context) {
    return [
      // Licence number field
      LabelItem(
        child: SizedBox(
          width: double.infinity,
          child: CustonPhoneTextField(
            controller: licenceNumberController,
            hintText: AppStrings.driverLicenceNumberHint,
            borderColor: AppColors.gray,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
            ],
            validator: (v) {
              final val = v?.trim() ?? '';
              if (val.length != 5) return 'Licence number must be 5 digits';
              if (int.tryParse(val) == null) {
                return 'Licence number must be numeric';
              }
              return null;
            },
          ),
        ),
      ),
      GapItem(Responsive.scaleClamped(context, 12, 8, 18)),
      // Expiry date field
      LabelItem(
        child: SizedBox(
          width: double.infinity,
          child: CustonPhoneTextField(
            controller: expiryDateController,
            hintText: AppStrings.driverLicenceExpiryHint,
            borderColor: AppColors.gray,
            inputFormatters: [
              ExtraInputFormatters.dateDmy,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: Validators.dateDMYFuture,
          ),
        ),
      ),
      GapItem(Responsive.scaleClamped(context, 6, 4, 12)),
      LabelItem(
        child: SizedBox(
          height: 18,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              showGlobalError
                  ? 'Please complete all fields and add images'
                  : '',
              style: TextStyle(
                color: showGlobalError
                    ? const Color(0xFFFF6B6B)
                    : Colors.transparent,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Form(
        key: formKey,
        child: DynamicFormBuilder(
          items: _buildItems(context),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
