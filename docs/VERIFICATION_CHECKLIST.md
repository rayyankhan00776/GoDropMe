# 📋 GoDropMe - Comprehensive Codebase Verification Checklist

> **Purpose**: File-by-file verification of all models, controllers, and pages against the Appwrite backend schema  
> **Created**: November 28, 2025  
> **Status**: ✅ VERIFICATION COMPLETE  
> **Flutter Analyze**: ✅ PASSED (0 issues)

---

## 🎯 Verification Summary

| Category | Files Verified | Status |
|----------|---------------|--------|
| **Core Config** | 3 | ✅ Complete |
| **Models (lib/models/)** | 4 | ✅ Complete |
| **Driver Registration Models** | 9 | ✅ Complete |
| **Driver Registration Controllers** | 7 | ✅ Complete |
| **Parent Side Models** | 6 | ✅ Complete |
| **Parent Side Controllers** | 1 | ✅ Complete |
| **Chat Models** | 4 | ✅ Complete |
| **Notification Models** | 2 | ✅ Complete |
| **Driver Home Models** | 3 | ✅ Complete |
| **Services** | 2 | ✅ Complete |
| **Shared Preferences** | 1 | ✅ Complete |

---

## ✅ 1. Core Configuration Files

### 1.1 `lib/main.dart` ✅
- [x] AppwriteClient.instance initialized
- [x] GetMaterialApp with proper routes
- [x] Theme configuration present
- [x] No hardcoded endpoints

### 1.2 `lib/config/environment.dart` ✅
- [x] `appwriteProjectId`: `68ed397e000f277c6936`
- [x] `appwritePublicEndpoint`: `https://fra.cloud.appwrite.io/v1`
- [x] Private constructor

### 1.3 `lib/routes.dart` ✅
- [x] All driver routes defined
- [x] All parent routes defined
- [x] Common routes defined
- [x] Route names consistent

---

## ✅ 2. Appwrite Client & Services

### 2.1 `lib/services/appwrite/appwrite_client.dart` ✅
- [x] Singleton pattern implemented
- [x] Uses Environment for config
- [x] `accountService()` helper
- [x] `databasesService()` helper
- [x] `storageService()` helper
- [ ] **TODO**: Add `realtimeService()` helper (for Phase 6)
- [ ] **TODO**: Add `functionsService()` helper (for Phase 5)

### 2.2 Services to Create (Phase 1-9)
- [ ] `auth_service.dart` - Email OTP (Phase 1)
- [ ] `database_constants.dart` - Collection IDs (Phase 1)
- [ ] `storage_service.dart` - File upload (Phase 2)
- [ ] `parent_service.dart` - Parent CRUD (Phase 2)
- [ ] `child_service.dart` - Child CRUD (Phase 2)
- [ ] `driver_service.dart` - Driver CRUD (Phase 3)
- [ ] `vehicle_service.dart` - Vehicle CRUD (Phase 3)
- [ ] `driver_config_service.dart` - Service config (Phase 3)
- [ ] `trip_service.dart` - Trip management (Phase 5)
- [ ] `chat_service.dart` - Chat & Realtime (Phase 6)
- [ ] `notification_service.dart` - Push notifications (Phase 7)

---

## ✅ 3. Shared Models (`lib/models/`)

### 3.1 `school.dart` ✅
**Schema Match**: ✅ Appwrite Compatible

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `name` | String | `schoolName` | ✅ |
| `lat` | double | `schoolLocation[1]` | ✅ |
| `lng` | double | `schoolLocation[0]` | ✅ |

- [x] `toJson()` outputs `[lng, lat]` for Appwrite point
- [x] `fromJson()` handles both Appwrite and legacy formats
- [x] `toAppwritePoint()` returns `[lng, lat]`
- [x] Legacy `toLegacyJson()` for local storage

### 3.2 `value_objects.dart` ✅
**Schema Match**: ✅ Appwrite Compatible

| Class | Fields | Status |
|-------|--------|--------|
| `PhoneNumber` | national, countryCode, e164 | ✅ |
| `Cnic` | digits (13 chars) | ✅ |
| `LatLngLite` | lat, lng | ✅ |
| `DayOfWeek` (enum) | mon-sun | ✅ (Not used in UI) |

- [x] `LatLngLite.toAppwritePoint()` → `[lng, lat]`
- [x] `LatLngLite.fromAppwritePoint()` ← `[lng, lat]`
- [x] `PhoneNumber.e164` returns `+92XXXXXXXXXX`

### 3.3 `parent_profile.dart` ✅
- [x] File exists (for parent profile data)

### 3.4 `catalog/` ✅
- [x] Catalog data for dropdowns

---

## ✅ 4. Driver Registration Models (`lib/features/DriverSide/driverRegistration/models/`)

### 4.1 `driver_name.dart` ✅
**Backend Collection**: `drivers`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `fullName` | String | `fullName` | ✅ |

- [x] `toJson()` present
- [x] `fromJson()` present

### 4.2 `personal_info.dart` ✅
**Backend Collection**: `drivers`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `firstName` | String | `firstName` | ✅ |
| `surName` | String | `surname` | ✅ |
| `lastName` | String | `lastName` | ✅ |
| `phone` | String? | `phone` | ✅ |
| `photoPath` | String? | (upload → `profilePhotoFileId`) | ✅ |

- [x] `toJson()` present
- [x] `fromJson()` present

### 4.3 `vehicle_selection.dart` ✅
**Backend Collection**: `vehicles`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `type` | VehicleType (enum) | `vehicleType` | ✅ |

- [x] `VehicleType.car` → "car"
- [x] `VehicleType.rikshaw` → "rikshaw"
- [x] `toJson()` present
- [x] `fromJson()` present

### 4.4 `vehicle_registration.dart` ✅
**Backend Collection**: `vehicles`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `brand` | String | `brand` | ✅ |
| `model` | String | `model` | ✅ |
| `color` | String | `color` | ✅ |
| `productionYear` | String | `productionYear` | ✅ |
| `numberPlate` | String | `numberPlate` | ✅ |
| `seatCapacity` | int | `seatCapacity` | ✅ |
| `vehiclePhotoPath` | String? | (upload → `vehiclePhotoFileId`) | ✅ |
| `certificateFrontPath` | String? | (upload → `registrationFrontFileId`) | ✅ |
| `certificateBackPath` | String? | (upload → `registrationBackFileId`) | ✅ |

- [x] `toJson()` present
- [x] `fromJson()` present
- [x] `seatCapacity` parsed as int

### 4.5 `driver_licence.dart` ✅
**Backend Collection**: `drivers`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `licenceNumber` | String | `licenseNumber` | ✅ |
| `expiry` | String | `licenseExpiry` (needs ISO conversion) | ✅ |
| `licencePhotoPath` | String? | (upload → `licensePhotoFileId`) | ✅ |
| `selfieWithLicencePath` | String? | (upload → `selfieWithLicenseFileId`) | ✅ |

- [x] `toJson()` present
- [x] `fromJson()` present
- [x] Date stored as string (DD-MM-YYYY), convert to ISO before backend

### 4.6 `driver_identification.dart` ✅
**Backend Collection**: `drivers`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `cnicNumber` | String | `cnicNumber` (13 digits) | ✅ |
| `expiryDate` | String? | `cnicExpiry` (needs ISO conversion) | ✅ |
| `idFrontPhotoPath` | String? | (upload → `cnicFrontFileId`) | ✅ |
| `idBackPhotoPath` | String? | (upload → `cnicBackFileId`) | ✅ |

- [x] `toJson()` present
- [x] `fromJson()` present

### 4.7 `service_details.dart` ✅
**Backend Collection**: `driver_services`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `schoolNames` | List<String> | `schoolNames` (string[]) | ✅ |
| `schoolPoints` | List<List<double>> | `schoolPoints` (point[]) | ✅ |
| `serviceCategory` | String? | `serviceCategory` (enum: Male/Female/Both) | ✅ |
| `serviceAreaCenter` | List<double>? | `serviceAreaCenter` (point [lng, lat]) | ✅ |
| `serviceAreaRadiusKm` | double? | `serviceAreaRadiusKm` (float) | ✅ |
| `serviceAreaPolygon` | List<List<List<double>>>? | `serviceAreaPolygon` (polygon 3D) | ✅ |
| `serviceAreaAddress` | String? | `serviceAreaAddress` | ✅ |
| `monthlyPricePkr` | int? | `monthlyPricePkr` (integer) | ✅ |
| `extraNotes` | String? | `extraNotes` | ✅ |

- [x] `toJson()` outputs correct formats
- [x] `fromJson()` handles Appwrite and legacy formats
- [x] `fromSchools()` factory for form submission
- [x] Polygon is 3D array `[[[lng, lat], ...]]` with closed ring
- [x] Schools converted from objects to parallel arrays

**Removed Fields** (confirmed not in model):
- ~~operatingDays~~ ✅ Removed
- ~~serviceWindow~~ ✅ Not in model
- ~~pickupRangeKm~~ ✅ Replaced by serviceAreaRadiusKm

### 4.8 `driver_service_options.dart` ✅
- [x] Supporting options for service details

### 4.9 `onboarding_draft.dart` ✅
- [x] Draft persistence support

---

## ✅ 5. Driver Registration Controllers (`lib/features/DriverSide/driverRegistration/controllers/`)

### 5.1 `driver_name_controller.dart` ✅
- [x] LocalStorage integration
- [x] Uses `StorageKeys.driverName`

### 5.2 `personal_info_controller.dart` ✅
- [x] LocalStorage integration
- [x] Uses `StorageKeys.personalInfo`

### 5.3 `vehicle_selection_controller.dart` ✅
- [x] LocalStorage integration
- [x] Uses `StorageKeys.vehicleSelection`

### 5.4 `vehicle_registration_controller.dart` ✅
- [x] LocalStorage integration
- [x] Uses `StorageKeys.vehicleRegistration`

### 5.5 `driver_licence_controller.dart` ✅
- [x] LocalStorage integration
- [x] Uses `StorageKeys.driverLicence`

### 5.6 `driver_identification_controller.dart` ✅
- [x] LocalStorage integration
- [x] Uses `StorageKeys.driverIdentification`

### 5.7 `service_details_controller.dart` ✅
- [x] LocalStorage integration
- [x] Uses `StorageKeys.driverServiceDetails`
- [x] `selectedSchools` for display
- [x] `selectedSchoolsData` for full data with lat/lng
- [x] `serviceCategory` (Rxn<String>)
- [x] `monthlyPricePkr` (RxnInt)
- [x] `saveServiceDetails()` method

---

## ✅ 6. Parent Side Models

### 6.1 `lib/features/parentSide/addChildren/models/child.dart` ✅
**Backend Collection**: `children`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `name` | String | `name` | ✅ |
| `age` | int | `age` (integer) | ✅ |
| `gender` | String | `gender` (enum) | ✅ |
| `schoolName` | String | `schoolName` | ✅ |
| `schoolLocation` | List<double>? | `schoolLocation` (point [lng, lat]) | ✅ |
| `pickPoint` | String | `pickPoint` | ✅ |
| `dropPoint` | String | `dropPoint` | ✅ |
| `relationshipToChild` | String | `relationshipToChild` | ✅ |
| `schoolOpenTime` | String? | `schoolOpenTime` | ✅ |
| `schoolOffTime` | String? | `schoolOffTime` | ✅ |
| `pickLocation` | List<double>? | `pickLocation` (point [lng, lat]) | ✅ |
| `dropLocation` | List<double>? | `dropLocation` (point [lng, lat]) | ✅ |

- [x] `toJson()` outputs `[lng, lat]` for all points
- [x] `fromJson()` handles legacy formats
- [x] `age` parsed as integer
- [x] Legacy `pickupTime` → `schoolOpenTime` migration

### 6.2 `lib/features/parentSide/findDrivers/models/driver_listing.dart` ✅
**For Display Only** (Combined from `drivers`, `vehicles`, `driver_services`)

| Field | Type | Source | Status |
|-------|------|--------|--------|
| `name` | String | drivers.fullName | ✅ |
| `vehicle` | String | vehicles.brand + model | ✅ |
| `vehicleColor` | String | vehicles.color | ✅ |
| `type` | String | vehicles.vehicleType | ✅ |
| `seatsAvailable` | int | vehicles.seatCapacity | ✅ |
| `serving` | String | driver_services.schoolNames[0] | ✅ |
| `serviceArea` | String | driver_services.serviceAreaAddress | ✅ |
| `serviceCategory` | String | driver_services.serviceCategory | ✅ |
| `monthlyPricePkr` | int | driver_services.monthlyPricePkr | ✅ |
| `extraNotes` | String | driver_services.extraNotes | ✅ |
| `photoAsset` | String | (for local demo) | ✅ |

- [x] `toJson()` present
- [x] `fromJson()` present
- [x] `demo()` factory for testing

---

## ✅ 7. Parent Side Controllers

### 7.1 `lib/features/parentSide/addChildren/controllers/add_children_controller.dart` ✅
- [x] `RxList<Map<String, dynamic>> children`
- [x] `loadChildren()` from LocalStorage
- [x] `addChild()` / `addChildModel()`
- [x] `updateChild()` / `updateChildModel()`
- [x] `deleteChild()` / `deleteChildModel()`
- [x] Uses `StorageKeys.childrenList`
- [x] `childModelAt()` for typed access

---

## ✅ 8. Chat Models

### 8.1 Parent Chat (`lib/features/parentSide/parentChat/models/`)

#### `chat_contact.dart` ✅
| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `id` | String | `$id` | ✅ |
| `name` | String | `driverName` | ✅ |
| `avatarUrl` | String? | (from storage) | ✅ |

- [x] `toJson()` present
- [x] `fromJson()` present

#### `chat_message.dart` ✅
| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `id` | String | `$id` | ✅ |
| `contactId` | String | `chatRoomId` | ✅ |
| `text` | String | `text` | ✅ |
| `fromMe` | bool | (derived from senderId) | ✅ |
| `time` | DateTime | `$createdAt` | ✅ |

- [x] `toJson()` with ISO 8601 datetime
- [x] `fromJson()` with DateTime parsing

### 8.2 Driver Chat (`lib/features/DriverSide/driverChat/models/`)

#### `chat_contact.dart` ✅
- [x] Same structure as parent chat contact
- [x] `toJson()` / `fromJson()` present

#### `chat_message.dart` ✅
- [x] Same structure as parent chat message
- [x] `toJson()` / `fromJson()` present

---

## ✅ 9. Notification Models

### 9.1 `lib/features/parentSide/notifications/models/parent_notification.dart` ✅
**Backend Collection**: `notifications`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `id` | String | `$id` | ✅ |
| `title` | String | `title` | ✅ |
| `subtitle` | String | `body` | ✅ |
| `time` | DateTime | `$createdAt` | ✅ |
| `type` | enum | `type` | ✅ |

- [x] `toJson()` with ISO 8601 datetime
- [x] `fromJson()` with DateTime parsing
- [x] Enum: pickup, dropoff, requestAccepted

### 9.2 `lib/features/DriverSide/notifications/models/driver_notification.dart` ✅
**Backend Collection**: `notifications`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `id` | String | `$id` | ✅ |
| `title` | String | `title` | ✅ |
| `subtitle` | String | `body` | ✅ |
| `time` | DateTime | `$createdAt` | ✅ |
| `type` | enum | `type` | ✅ |

- [x] `toJson()` with ISO 8601 datetime
- [x] `fromJson()` with DateTime parsing
- [x] Enum: newRequest, childPresent, childAbsent

---

## ✅ 10. Driver Home Models (`lib/features/DriverSide/driverHome/models/`)

### 10.1 `driver_order.dart` ✅
**Backend Collections**: `trips`, `active_services`

| Field | Type | Backend Source | Status |
|-------|------|----------------|--------|
| `id` | String | trips.$id | ✅ |
| `parentName` | String | parents.fullName | ✅ |
| `avatarUrl` | String? | parents.profilePhotoFileId | ✅ |
| `schoolName` | String | children.schoolName | ✅ |
| `pickPoint` | String | children.pickPoint | ✅ |
| `dropPoint` | String | children.dropPoint | ✅ |
| `status` | enum | trips.status | ✅ |

- [x] `toJson()` present
- [x] `fromJson()` present
- [x] Enum: pendingPickup, picked, dropped

### 10.2 `driver_request.dart` ✅
**Backend Collection**: `service_requests`

| Field | Type | Backend Field | Status |
|-------|------|---------------|--------|
| `id` | String | `$id` | ✅ |
| `parentName` | String | parents.fullName | ✅ |
| `avatarUrl` | String? | parents.profilePhotoFileId | ✅ |
| `schoolName` | String | children.schoolName | ✅ |
| `pickPoint` | String | children.pickPoint | ✅ |
| `dropPoint` | String | children.dropPoint | ✅ |

- [x] `toJson()` present
- [x] `fromJson()` present

### 10.3 `driver_map.dart` ✅
- [x] `ChildPickup` model with `toJson()`
- [x] Map marker data

---

## ✅ 11. Shared Preferences (`lib/sharedPrefs/`)

### 11.1 `local_storage.dart` ✅
**StorageKeys** (all verified):

| Key | Used By | Status |
|-----|---------|--------|
| `driverName` | DriverNameController | ✅ |
| `vehicleSelection` | VehicleSelectionController | ✅ |
| `personalInfo` | PersonalInfoController | ✅ |
| `driverLicence` | DriverLicenceController | ✅ |
| `driverIdentification` | DriverIdentificationController | ✅ |
| `vehicleRegistration` | VehicleRegistrationController | ✅ |
| `driverServiceDetails` | ServiceDetailsController | ✅ |
| `childrenList` | AddChildrenController | ✅ |
| `parentName` | ParentNameController | ✅ |
| `parentPhone` | (unused yet) | ✅ |
| `driverPhone` | (unused yet) | ✅ |
| `parentEmail` | EmailController | ✅ |
| `driverEmail` | EmailController | ✅ |

- [x] `LocalStorage.setJson()` / `getJson()`
- [x] `LocalStorage.getJsonList()` / `replaceJsonList()`

---

## ✅ 12. Assets (`assets/json/`)

### 12.1 `driver_details.json` ✅
```json
{
  "serviceCategories": ["Male", "Female", "Both"]
}
```
- [x] Contains `serviceCategories` array
- [x] Used by service details form dropdown

### 12.2 `schools.json` ✅
- [x] Contains Peshawar area schools
- [x] Each entry has name, lat, lng

### 12.3 Other JSONs ✅
- [x] `car_details.json` - Car brands/models
- [x] `rikshaw_details.json` - Rikshaw details
- [x] `children_details.json` - Age ranges, relationships

---

## 📊 Geo Format Verification Summary

### All Locations Use [lng, lat] ✅

| Model | Field | Format | Status |
|-------|-------|--------|--------|
| ChildModel | schoolLocation | [lng, lat] | ✅ |
| ChildModel | pickLocation | [lng, lat] | ✅ |
| ChildModel | dropLocation | [lng, lat] | ✅ |
| ServiceDetails | schoolPoints | [[lng, lat], ...] | ✅ |
| ServiceDetails | serviceAreaCenter | [lng, lat] | ✅ |
| ServiceDetails | serviceAreaPolygon | [[[lng, lat], ...]] | ✅ |
| School | location (toJson) | [lng, lat] | ✅ |
| LatLngLite | toAppwritePoint() | [lng, lat] | ✅ |

---

## 🔴 Missing Components (Pre-Backend)

### To Create Before Backend Implementation:

1. **`lib/services/appwrite/database_constants.dart`**
```dart
class DatabaseConstants {
  static const String databaseId = 'godropme_db';
  static const String usersCollection = 'users';
  static const String parentsCollection = 'parents';
  static const String childrenCollection = 'children';
  static const String driversCollection = 'drivers';
  static const String vehiclesCollection = 'vehicles';
  static const String driverServicesCollection = 'driver_services';
  static const String serviceRequestsCollection = 'service_requests';
  static const String activeServicesCollection = 'active_services';
  static const String tripsCollection = 'trips';
  static const String chatRoomsCollection = 'chat_rooms';
  static const String messagesCollection = 'messages';
  static const String notificationsCollection = 'notifications';
  static const String reportsCollection = 'reports';
  static const String geofenceEventsCollection = 'geofence_events';
  
  // Storage Buckets
  static const String profilePhotosBucket = 'profile_photos';
  static const String documentsBucket = 'documents';
  static const String vehiclePhotosBucket = 'vehicle_photos';
  static const String childPhotosBucket = 'child_photos';
  static const String chatAttachmentsBucket = 'chat_attachments';
  static const String reportAttachmentsBucket = 'report_attachments';
}
```

2. **`lib/services/appwrite/auth_service.dart`**
```dart
// Email OTP authentication service
// - sendEmailOTP(email)
// - verifyOTP(userId, otp)
// - getCurrentUser()
// - logout()
```

---

## ✅ Final Verification Status

| Check | Status |
|-------|--------|
| Flutter Analyze | ✅ PASSED (0 issues) |
| All Models have toJson() | ✅ |
| All Models have fromJson() | ✅ |
| Geo formats are [lng, lat] | ✅ |
| serviceCategory field added | ✅ |
| operatingDays removed | ✅ |
| monthlyPricePkr added | ✅ |
| schoolOpenTime/schoolOffTime in ChildModel | ✅ |
| LocalStorage keys match controllers | ✅ |
| Asset JSONs contain required data | ✅ |

---

## 🎯 Next Steps

1. **Phase 1**: Create Appwrite Console collections (see `TODO.md`)
2. **Phase 1**: Create `database_constants.dart` and `auth_service.dart`
3. **Phase 1**: Implement Email OTP flow
4. **Phase 2**: Parent registration with backend
5. **Phase 3**: Driver registration with backend
6. Continue per `TODO.md` phases...

---

> **Verified By**: Comprehensive file-by-file code review  
> **Date**: November 28, 2025  
> **Result**: ✅ All models and controllers are Appwrite-compatible
