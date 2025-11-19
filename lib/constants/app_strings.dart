// Barrel file exporting domain-specific string groups.
// Existing imports of `app_strings.dart` remain valid.
// For backward compatibility, AppStrings continues to expose the same static constants
// but internally delegates to grouped domain classes.

export 'common_strings.dart';
export 'driver_strings.dart';
export 'parent_strings.dart';
export 'validation_strings.dart';

import 'common_strings.dart';
import 'driver_strings.dart';
import 'parent_strings.dart';
import 'validation_strings.dart';

class AppStrings {
  // Common
  static const next = CommonStrings.next;
  static const close = CommonStrings.close;
  static const ok = CommonStrings.ok;
  static const cancel = CommonStrings.cancel;
  static const settings = CommonStrings.settings;
  static const enable = CommonStrings.enable;
  static const report = CommonStrings.report;
  static const send = CommonStrings.send;
  static const done = CommonStrings.done;
  static const optionalLabel = CommonStrings.optionalLabel;
  static const tapToSelect = CommonStrings.tapToSelect;
  static const tapToSelectOnMap = CommonStrings.tapToSelectOnMap;
  static const sameAsPick = CommonStrings.sameAsPick;
  static const useThisLocation = CommonStrings.useThisLocation;
  static const loadingOptions = CommonStrings.loadingOptions;
  static const loadingCatalog = CommonStrings.loadingCatalog;
  static const error = CommonStrings.error;
  static const unableToOpenCameraPrefix =
      CommonStrings.unableToOpenCameraPrefix;
  static const onboardTitle1 = CommonStrings.onboardTitle1;
  static const onboardSubtitle1 = CommonStrings.onboardSubtitle1;
  static const onboardTitle2 = CommonStrings.onboardTitle2;
  static const onboardSubtitle2 = CommonStrings.onboardSubtitle2;
  static const onboardTitle3 = CommonStrings.onboardTitle3;
  static const onboardSubtitle3 = CommonStrings.onboardSubtitle3;
  static const onboardButton = CommonStrings.onboardButton;
  static const onboardSkip = CommonStrings.onboardSkip;
  static const optionHeading = CommonStrings.optionHeading;
  static const optionLine1 = CommonStrings.optionLine1;
  static const optionLine2 = CommonStrings.optionLine2;
  static const continueWithPhone = CommonStrings.continueWithPhone;
  static const continueWithGoogle = CommonStrings.continueWithGoogle;
  static const optionTermsPrefix = CommonStrings.optionTermsPrefix;
  static const optionTermsText = CommonStrings.optionTermsText;
  static const optionPrivacyText = CommonStrings.optionPrivacyText;
  static const dopheading = CommonStrings.dopheading;
  static const dopsubheading = CommonStrings.dopsubheading;
  static const phoneTitle = CommonStrings.phoneTitle;
  static const phoneSubtitle = CommonStrings.phoneSubtitle;
  static const phoneHint = CommonStrings.phoneHint;
  static const otpTitle = CommonStrings.otpTitle;
  static const otpSubtitle = CommonStrings.otpSubtitle;
  static const otpverify = CommonStrings.otpverify;
  static const changeNumber = CommonStrings.changeNumber;
  // Update phone flow
  static const updatePhoneTitle = CommonStrings.updatePhoneTitle;
  static const updatePhoneSubtitle = CommonStrings.updatePhoneSubtitle;
  static const updatePhoneButton = CommonStrings.updatePhoneButton;
  static const updateOtpTitle = CommonStrings.updateOtpTitle;
  static const updateOtpSubtitle = CommonStrings.updateOtpSubtitle;
  static const updateOtpVerify = CommonStrings.updateOtpVerify;
  static const reportGuideline1 = CommonStrings.reportGuideline1;
  static const reportGuideline2 = CommonStrings.reportGuideline2;
  static const reportHint = CommonStrings.reportHint;
  static const reportSent = CommonStrings.reportSent;

  // Parent
  static const parentNameTitle = ParentStrings.parentNameTitle;
  static const parentNameSubtitle = ParentStrings.parentNameSubtitle;
  static const parentNameButton = ParentStrings.parentNameButton;
  static const drawerAddChildren = ParentStrings.drawerAddChildren;
  static const drawerFindDrivers = ParentStrings.drawerFindDrivers;
  static const drawerSettings = ParentStrings.drawerSettings;
  static const drawerSupport = ParentStrings.drawerSupport;
  static const drawerTerms = ParentStrings.drawerTerms;
  static const drawerMapScreen = ParentStrings.drawerMapScreen;
  static const drawerRateUs = ParentStrings.drawerRateUs;
  static const drawerLogout = ParentStrings.drawerLogout;
  static const drawerVersionLabel = ParentStrings.drawerVersionLabel;
  static const drawerProfileNamePlaceholder =
      ParentStrings.drawerProfileNamePlaceholder;
  static const drawerProfileRoleParent = ParentStrings.drawerProfileRoleParent;
  static const addChildTitle = ParentStrings.addChildTitle;
  static const childNameHint = ParentStrings.childNameHint;
  static const childAgeHint = ParentStrings.childAgeHint;
  static const childGenderHint = ParentStrings.childGenderHint;
  static const childSchoolHint = ParentStrings.childSchoolHint;
  static const childPickPointHint = ParentStrings.childPickPointHint;
  static const childDropPointHint = ParentStrings.childDropPointHint;
  static const childRelationshipHint = ParentStrings.childRelationshipHint;
  static const childPickupTimePref = ParentStrings.childPickupTimePref;
  static const addChildSave = ParentStrings.addChildSave;
  static const parentChatHeading = ParentStrings.parentChatHeading;
  static const profileTitle = ParentStrings.profileTitle;
  static const addChildrenTitle = ParentStrings.addChildrenTitle;
  static const noChildrenAdded = ParentStrings.noChildrenAdded;
  static const yourChildren = ParentStrings.yourChildren;
  static const timeNotSet = ParentStrings.timeNotSet;

  // Driver
  static const driverOnlineLabel = DriverStrings.driverOnlineLabel;
  static const driverOfflineLabel = DriverStrings.driverOfflineLabel;
  static const driverOfflineMessage = DriverStrings.driverOfflineMessage;
  static const driverNameTitle = DriverStrings.driverNameTitle;
  static const driverNameSubtitle = DriverStrings.driverNameSubtitle;
  static const driverNameButton = DriverStrings.driverNameButton;
  static const chooseVehicleTitle = DriverStrings.chooseVehicleTitle;
  static const vehicleCar = DriverStrings.vehicleCar;
  static const vehicleRickshaw = DriverStrings.vehicleRickshaw;
  static const personalInfoTitle = DriverStrings.personalInfoTitle;
  static const help = DriverStrings.help;
  static const personalInfoHelpLine1 = DriverStrings.personalInfoHelpLine1;
  static const personalInfoHelpLine2 = DriverStrings.personalInfoHelpLine2;
  static const personalInfoTakeNewPicture =
      DriverStrings.personalInfoTakeNewPicture;
  static const personalInfoImageLabel = DriverStrings.personalInfoImageLabel;
  static const personalInfoCnicNote = DriverStrings.personalInfoCnicNote;
  static const firstNameHint = DriverStrings.firstNameHint;
  static const surNameHint = DriverStrings.surNameHint;
  static const lastNameHint = DriverStrings.lastNameHint;
  static const driverLicenseNote = DriverStrings.driverLicenseNote;
  static const driverLicenceTitle = DriverStrings.driverLicenceTitle;
  static const driverLicenseSelfieLabel =
      DriverStrings.driverLicenseSelfieLabel;
  static const driverLicenceHelpLine1 = DriverStrings.driverLicenceHelpLine1;
  static const driverLicenceHelpLine2 = DriverStrings.driverLicenceHelpLine2;
  static const driverLicenceSelfieHelpLine1 =
      DriverStrings.driverLicenceSelfieHelpLine1;
  static const driverLicenceSelfieHelpLine2 =
      DriverStrings.driverLicenceSelfieHelpLine2;
  static const driverLicenceTakeNewPicture =
      DriverStrings.driverLicenceTakeNewPicture;
  static const driverLicenceNumberHint = DriverStrings.driverLicenceNumberHint;
  static const driverLicenceExpiryHint = DriverStrings.driverLicenceExpiryHint;
  static const driverIdentificationTitle =
      DriverStrings.driverIdentificationTitle;
  static const cnicFrontHint = DriverStrings.cnicFrontHint;
  static const idFrontTitle = DriverStrings.idFrontTitle;
  static const idBackTitle = DriverStrings.idBackTitle;
  static const driverIdentificationNote =
      DriverStrings.driverIdentificationNote;
  static const vehicleRegistrationTitle =
      DriverStrings.vehicleRegistrationTitle;
  static const vehiclePhotoLabel = DriverStrings.vehiclePhotoLabel;
  static const vehicleCertFrontLabel = DriverStrings.vehicleCertFrontLabel;
  static const vehicleCertBackLabel = DriverStrings.vehicleCertBackLabel;
  static const vehicleDetailsNote = DriverStrings.vehicleDetailsNote;
  static const vehicleBrandHint = DriverStrings.vehicleBrandHint;
  static const vehicleModelHint = DriverStrings.vehicleModelHint;
  static const vehicleColorHint = DriverStrings.vehicleColorHint;
  static const vehicleProductionYearHint =
      DriverStrings.vehicleProductionYearHint;
  static const vehicleNumberPlateHint = DriverStrings.vehicleNumberPlateHint;
  static const vehicleSeatCapacityHint = DriverStrings.vehicleSeatCapacityHint;
  static const vehiclePhotoHelpLine1 = DriverStrings.vehiclePhotoHelpLine1;
  static const vehiclePhotoHelpLine2 = DriverStrings.vehiclePhotoHelpLine2;
  static const vehicleCertHelpLine1 = DriverStrings.vehicleCertHelpLine1;
  static const vehicleCertHelpLine2 = DriverStrings.vehicleCertHelpLine2;
  static const vehicleTakeNewPicture = DriverStrings.vehicleTakeNewPicture;
  static const vehicleDetailsSaved = DriverStrings.vehicleDetailsSaved;
  static const driverTabRequests = DriverStrings.driverTabRequests;
  static const driverTabOrders = DriverStrings.driverTabOrders;
  static const driverTabMaps = DriverStrings.driverTabMaps;
  static const driverTabChat = DriverStrings.driverTabChat;
  static const schoolNamesHint = DriverStrings.schoolNamesHint;
  static const dutyTypeHint = DriverStrings.dutyTypeHint;
  static const pickupRangeKmHint = DriverStrings.pickupRangeKmHint;
  static const routeStartPointLabel = DriverStrings.routeStartPointLabel;
  static const operatingDaysHint = DriverStrings.operatingDaysHint;
  static const extraNotesHint = DriverStrings.extraNotesHint;
  static const activeStatus = DriverStrings.activeStatus;
  static const activeStatusSubtitle = DriverStrings.activeStatusSubtitle;

  // Validation
  static const formGlobalError = ValidationStrings.formGlobalError;
  static const childFormGlobalError = ValidationStrings.childFormGlobalError;
  static const unableToSubmitForm = ValidationStrings.unableToSubmitForm;
  static const requiredFieldsMissing = ValidationStrings.requiredFieldsMissing;
  static const firstNameRequired = ValidationStrings.firstNameRequired;
  static const errorCnicDigits = ValidationStrings.errorCnicDigits;
  static const errorCnicNumeric = ValidationStrings.errorCnicNumeric;
  static const errorExpiryRequired = ValidationStrings.errorExpiryRequired;
  static const errorExpiryFormat = ValidationStrings.errorExpiryFormat;
  static const errorExpiryMonth = ValidationStrings.errorExpiryMonth;
  static const errorExpiryDay = ValidationStrings.errorExpiryDay;
  static const errorSeatCapacityRequired =
      ValidationStrings.errorSeatCapacityRequired;
  static const errorSeatCapacityInvalid =
      ValidationStrings.errorSeatCapacityInvalid;
  static const seatCapacityMaxLabelPrefix =
      ValidationStrings.seatCapacityMaxLabelPrefix;
  static const errorYearRequired = ValidationStrings.errorYearRequired;
  static const errorYearLength = ValidationStrings.errorYearLength;
  static const errorYearInvalid = ValidationStrings.errorYearInvalid;
  static const errorPlateRequired = ValidationStrings.errorPlateRequired;
  static const fullNameHint = ValidationStrings.fullNameHint;
  static const enterFullName = ValidationStrings.enterFullName;
}
