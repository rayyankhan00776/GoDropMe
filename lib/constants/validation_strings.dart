class ValidationStrings {
  // Global form errors
  static const formGlobalError = 'Please complete all fields and add images';
  static const childFormGlobalError = 'Please fill all the details';
  static const unableToSubmitForm = 'Unable to submit form';
  static const requiredFieldsMissing = 'Please complete required fields';

  // Personal info validations
  static const firstNameRequired = 'Please enter first name';

  // CNIC / ID validations
  static const errorCnicDigits = 'CNIC must be 13 digits';
  static const errorCnicNumeric = 'CNIC must be numeric';

  // Date validations
  static const errorExpiryRequired = 'Please enter expiry date';
  static const errorExpiryFormat = 'Enter date as DD-MM-YYYY';
  static const errorExpiryMonth = 'Enter valid month';
  static const errorExpiryDay = 'Enter valid day';

  // Vehicle validations
  static const errorSeatCapacityRequired = 'Please enter seat capacity';
  static const errorSeatCapacityInvalid = 'Enter a valid capacity';
  static const seatCapacityMaxLabelPrefix = 'Max allowed seats:';
  static const errorYearRequired = 'Please enter production year';
  static const errorYearLength = 'Year must be 4 digits';
  static const errorYearInvalid = 'Enter a valid year';
  static const errorPlateRequired = 'Please enter number plate';

  // Names input
  static const fullNameHint = 'Full Name';
  static const enterFullName = 'Please enter full name';
}
