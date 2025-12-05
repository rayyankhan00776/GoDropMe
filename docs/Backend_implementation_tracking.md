# 📊 GoDropMe - Backend Implementation Tracking

> **Project**: GoDropMe - School Children Transportation App  
> **Backend**: Appwrite Cloud (fra.cloud.appwrite.io)  
> **Project ID**: `68ed397e000f277c6936`  
> **Database ID**: `godropme_db`  
> **Last Updated**: December 3, 2025

---

## ✅ Implementation Status Overview

| Component | Status | Notes |
|-----------|--------|-------|
| **Appwrite Database** | ✅ Complete | 18 tables created (added `schools`) |
| **Storage Buckets** | ✅ Complete | 6 buckets created + permissions set |
| **Messaging Topics** | ✅ Complete | 6 topics created |
| **Collection Permissions** | ✅ Complete | All 18 tables have CRUD for users |
| **Auth Service** | ✅ Complete | Email OTP + `hasDriverProfile` tracking |
| **Storage Service** | ✅ Complete | File upload with compression |
| **Parent Service** | ✅ Complete | CRUD operations, uses TablesDB |
| **Child Service** | ✅ Complete | CRUD operations, uses TablesDB |
| **Driver Service** | ✅ Complete | CRUD for `drivers` table |
| **Vehicle Service** | ✅ Complete | CRUD for `vehicles` table |
| **Driver Config Service** | ✅ Complete | CRUD for `driver_services` table |
| **Driver Registration Service** | ✅ Complete | Orchestrates complete registration |
| **UI Integration** | ✅ Complete | Controllers bound to services |
| **First-time User Flow** | ✅ Complete | Splash → Onboard → Option |
| **Session Management** | ✅ Complete | Auto-restore + incomplete registration resume |
| **Parent Registration** | ✅ Complete | Full flow tested & working |
| **Driver Registration** | ✅ Complete | Full flow tested & working |
| **AppwriteImage Widget** | ✅ Complete | Authenticated image loading from storage |
| **Profile Edit Sync** | ✅ Complete | Name, Phone sync to Account + Users + Parents |
| **Settings Actions** | ⚠️ Partial | Logout works, Delete Account incomplete |
| **TablesDB Migration** | ✅ Complete | All services migrated from deprecated Databases API |
| **Driver Model Alignment** | ✅ Complete | All models aligned with Appwrite schema |
| **Schools Table** | ✅ Complete | Central lookup table with 32 schools seeded |
| **SchoolsLoader** | ✅ Complete | Fetches from Appwrite only (no JSON fallback) |
| **School FK Refactor** | ✅ Complete | `schoolId`/`schoolIds` replace names everywhere |
| **Status Unification** | ✅ Complete | All status managed in `users.status` only |

---

## 🔄 Status Unification (December 3, 2025 - Latest)

### Problem: Redundant Status Fields

Previously had:
- `users.status` → `pending`, `active`, `suspended`, `rejected`
- `drivers.verificationStatus` → `pending`, `verified`, `rejected`
- `users.suspensionReason` and `users.rejectionReason` (two separate columns)

This caused confusion about which field to check and duplication in status management.

### Solution: Single Source of Truth

**Unified to `users.status` only:**

| Change | Details |
|--------|---------|
| `users.status` | ✅ KEPT - Single source of truth |
| `users.statusReason` | ✅ NEW - Single column for suspension/rejection reasons |
| `users.suspensionReason` | ❌ DELETED - Merged into `statusReason` |
| `users.rejectionReason` | ❌ DELETED - Merged into `statusReason` |
| `drivers.verificationStatus` | ❌ DELETED - No longer needed |

### Database Operations Performed

```bash
# Via MCP Appwrite API Tools
1. mcp_appwrite-api_tables_db_delete_column (users.suspensionReason)
2. mcp_appwrite-api_tables_db_delete_column (users.rejectionReason)
3. mcp_appwrite-api_tables_db_create_string_column (users.statusReason, size=500)
4. mcp_appwrite-api_tables_db_delete_column (drivers.verificationStatus)
```

### Updated Constants

```dart
// lib/services/appwrite/database_constants.dart
class CollectionEnums {
  // User status values (unified - used for all status checks)
  static const String statusPending = 'pending';
  static const String statusActive = 'active';
  static const String statusSuspended = 'suspended';
  static const String statusRejected = 'rejected';
}
```

### Code Files Modified

| File | Changes |
|------|---------|
| `auth_service.dart` | Reads `status` and `statusReason` from users table only |
| `driver_service.dart` | Removed `verificationStatus` writes; sets `users.status` |
| `lib/models/driver.dart` | Removed `verificationStatus` field and enum |
| `splash_controller.dart` | Uses `CollectionEnums.status*`; passes `statusReason` |
| `otp_controller.dart` | Same routing logic as splash_controller |
| `database_constants.dart` | Added `statusPending`, `statusActive`, etc. |

### AuthResult Changes

```dart
// Before (two fields)
class AuthResult {
  final String? suspensionReason;
  final String? rejectionReason;
}

// After (one field)
class AuthResult {
  final String? statusReason; // Used for both suspended and rejected
}
```

### Routing Logic

```dart
switch (result.status) {
  case CollectionEnums.statusActive:
    if (result.userRole == CollectionEnums.roleParent) {
      Get.offAllNamed(AppRoutes.parentmapScreen);
    } else if (result.userRole == CollectionEnums.roleDriver) {
      if (!result.hasDriverProfile) {
        Get.offAllNamed(AppRoutes.vehicleSelection); // Resume registration
      } else {
        Get.offAllNamed(AppRoutes.driverMap);
      }
    }
    break;
    
  case CollectionEnums.statusPending:
    Get.offAllNamed(AppRoutes.driverPendingApproval);
    break;
    
  case CollectionEnums.statusRejected:
    Get.offAllNamed(AppRoutes.driverRejected,
      arguments: {'reason': result.statusReason ?? 'No reason provided'});
    break;
    
  case CollectionEnums.statusSuspended:
    Get.offAllNamed(AppRoutes.driverSuspended,
      arguments: {'reason': result.statusReason ?? 'No reason provided'});
    break;
}
```

### Benefits

1. **Single Source of Truth**: Only check `users.status` for any status
2. **Cleaner Schema**: One `statusReason` instead of two similar columns
3. **Type Safety**: Use `CollectionEnums.status*` constants instead of strings
4. **Simpler Code**: No need to sync status between tables

---

## 🚗 Phase 3: Driver Registration Backend (December 3, 2025 - COMPLETE)

### Services Implemented

#### DriverService (`lib/services/appwrite/driver_service.dart`)

| Method | Purpose |
|--------|---------|
| `createDriver()` | ❌ DEPRECATED - doesn't include all required fields |
| `createDriverComplete()` | ✅ Creates driver with ALL required fields + uploads ALL photos |
| `getDriver()` | Get driver by current auth userId |
| `getDriverById()` | Get driver by driverId |
| `updatePersonalInfo()` | Update name, phone, profile photo |
| `updateIdentification()` | Update CNIC info + photos |
| `updateLicense()` | Update license info + photos |
| `setOnlineStatus()` | Set driver online/offline |
| `updateLocation()` | Update driver's current location |
| `completeRegistration()` | Mark registration as complete |
| `deleteDriver()` | Delete driver and all associated photos |

#### VehicleService (`lib/services/appwrite/vehicle_service.dart`)

| Method | Purpose |
|--------|---------|
| `createVehicle()` | Create vehicle with photos |
| `getVehicleByDriver()` | Get vehicle for a driver |
| `getVehicleById()` | Get vehicle by ID |
| `updateVehicle()` | Update vehicle info |
| `deleteVehicle()` | Delete vehicle and photos |

#### DriverConfigService (`lib/services/appwrite/driver_config_service.dart`)

| Method | Purpose |
|--------|---------|
| `createServiceConfig()` | Create driver service configuration |
| `getServiceConfig()` | Get config by driver ID |
| `updateServiceConfig()` | Update service details |
| `deleteServiceConfig()` | Delete service config |

#### DriverRegistrationService (`lib/services/appwrite/driver_registration_service.dart`)

| Method | Purpose |
|--------|---------|
| `submitRegistration()` | Orchestrates complete registration submission |
| `clearLocalData()` | Clear all local registration data after success |

### Key Implementation: `createDriverComplete()`

The Appwrite `drivers` table has many **REQUIRED** fields. Cannot create with partial data then update later.

**Solution**: Single method that:
1. Uploads ALL 5 photos in parallel (profile, CNIC front/back, license, selfie)
2. Creates driver row with ALL required fields in single `createRow()` call

```dart
Future<DriverResult> createDriverComplete({
  required PersonalInfo personalInfo,
  required String email,
  required DriverIdentification identification,
  required DriverLicence licence,
  required File profilePhoto,
  required File cnicFront,
  required File cnicBack,
  required File licensePhoto,
  required File selfieWithLicense,
}) async {
  // 1. Upload all photos in parallel
  final uploadResults = await Future.wait([...]);
  
  // 2. Create driver row with ALL fields
  final driverRow = await _tablesDB.createRow(
    tableId: Collections.drivers,
    data: {
      'userId': authUserId,  // From users table $id
      'fullName': ...,
      'cnicNumber': ...,     // Required
      'cnicFrontUrl': ...,   // Required
      'cnicBackUrl': ...,    // Required
      'licenseNumber': ...,  // Required
      'licensePhotoUrl': ..., // Required
      // ... all other fields
    },
  );
}
```

### CNIC Sanitization

User input format: `17301-4753215-4` (15 chars)
Database format: `1730147532154` (13 digits)

```dart
String _sanitizeCnic(String cnic) {
  return cnic.replaceAll(RegExp(r'[^0-9]'), '');
}
```

---

## 🔐 Driver Auth Flow Enhancement (December 3, 2025)

### Problem: Driver users not in `users` table

Parent flow creates user in `users` + `parents` tables at name entry.
Driver flow was only creating `drivers` table at end of registration.
This caused auth issues: "New user - no record in database"

### Solution: Mirror Parent Flow

| Step | Action |
|------|--------|
| Driver Name Screen | Create user in `users` table (role: driver) |
| Complete Registration | Create `drivers`, `vehicles`, `driver_services` tables |

### Files Modified

#### `auth_service.dart`

```dart
// registerUser() now only creates users row for drivers
// (not drivers row - that's created later with all documents)
if (role == CollectionEnums.roleDriver) {
  // Only users row created here
  // Driver profile created at end of registration
}
```

#### `driver_name_controller.dart`

```dart
// Added registerDriver() method
Future<bool> registerDriver() async {
  final result = await AuthService.instance.registerUser(
    role: CollectionEnums.roleDriver,
    fullName: name.value.trim(),
    email: authUser.email,
  );
  // Creates users table row only
}
```

### Incomplete Registration Resume

Added `hasDriverProfile` flag to detect incomplete registration:

#### `AuthResult` class

```dart
class AuthResult {
  final bool success;
  final String message;
  final String? userId;
  final String? email;
  final bool? isNewUser;
  final String? userRole;
  final String? status;          // From users.status (unified)
  final String? statusReason;    // For suspended/rejected reasons
  final bool hasDriverProfile;   // true if driver row exists
}
```

#### `_checkUserInDatabase()` method

```dart
// Now reads status from users table only
final status = userRow.data['status'];
final statusReason = userRow.data['statusReason'];

if (role == CollectionEnums.roleDriver) {
  final driverResponse = await _tablesDB.listRows(
    tableId: Collections.drivers,
    queries: [Query.equal('userId', userRow.$id)],
  );
  
  hasDriverProfile = driverResponse.rows.isNotEmpty;
  // Note: verificationStatus no longer exists in drivers table
  // All status checks now use users.status
}
```

#### Routing Logic (splash_controller.dart, otp_controller.dart)

```dart
if (role == CollectionEnums.roleDriver) {
  if (!hasDriverProfile) {
    // Incomplete registration - resume at vehicle selection
    Get.offAllNamed(AppRoutes.vehicleSelection);
    return;
  }
  
  // Complete registration - route by unified status
  switch (status) {
    case CollectionEnums.statusActive: 
      Get.offAllNamed(AppRoutes.driverMap);
      break;
    case CollectionEnums.statusPending: 
      Get.offAllNamed(AppRoutes.driverPendingApproval);
      break;
    case CollectionEnums.statusRejected: 
      Get.offAllNamed(AppRoutes.driverRejected,
        arguments: {'reason': statusReason ?? 'No reason provided'});
      break;
    case CollectionEnums.statusSuspended: 
      Get.offAllNamed(AppRoutes.driverSuspended,
        arguments: {'reason': statusReason ?? 'No reason provided'});
      break;
  }
}
```

### Profile Complete Flag

When driver submits full registration:

```dart
// driver_registration_service.dart → _markProfileComplete()
await AppwriteClient.tablesDBService().updateRow(
  databaseId: AppwriteConfig.databaseId,
  tableId: Collections.users,
  rowId: authUser.$id,
  data: {'isProfileComplete': true},
);
```

---

## 🔗 School ID Foreign Keys (December 3, 2025 - Latest)

### Refactoring: Names → IDs (Cleanup Complete)

Refactored to use school IDs as foreign keys. **All deprecated fields removed.**

### Final Schema

#### `children` Table

| Column | Status | Type | Notes |
|--------|--------|------|-------|
| `schoolId` | ✅ **ACTIVE** | string(36) | FK to schools.$id |
| `schoolName` | ❌ **DELETED** | - | Removed from Appwrite |
| `schoolLocation` | ❌ **DELETED** | - | Removed from Appwrite |

#### `driver_services` Table

| Column | Status | Type | Notes |
|--------|--------|------|-------|
| `schoolIds` | ✅ **ACTIVE** | string[](36) | FK array to schools.$id |
| `schoolNames` | ❌ **DELETED** | - | Removed from Appwrite |
| `schoolPoints` | ❌ **NEVER EXISTED** | - | Not supported by Appwrite |

### Code Files Updated (Final)

| File | Changes |
|------|---------|
| `lib/models/school.dart` | Has `id` field from `$id` |
| `lib/models/driver_service.dart` | Uses only `schoolIds` |
| `lib/features/.../child.dart` | Uses only `schoolId` (no `schoolName`) |
| `lib/features/.../service_details.dart` | Uses only `schoolIds` |
| `lib/utils/schools_loader.dart` | `getById()`, `getByIds()` methods |
| `lib/services/appwrite/child_service.dart` | `_buildChildData()` uses `schoolId` only |
| `lib/features/.../add_child_form.dart` | Saves `schoolId` only |
| `lib/features/.../child_tile.dart` | Looks up school name from `schoolId` |
| `lib/features/.../profile_screen.dart` | Looks up school names from IDs |

### Data Flow (Final)

```
Form Selection → Save ID(s) → Display: Lookup name from ID
     ↓               ↓                    ↓
schoolName    →  schoolId     →  SchoolsLoader.getById()
schoolNames[] →  schoolIds[]  →  SchoolsLoader.getByIds()
```

---

## 🏫 Schools Backend (December 3, 2025)

### Problem Solved: schoolPoints (point[] not supported)

Appwrite doesn't support `point[]` (array of geographic points). Drivers serve multiple schools, so we needed a solution.

**Solution**: Central `schools` lookup table

### Schools Table Schema

| Column | Type | Required | Default | Index |
|--------|------|----------|---------|-------|
| `name` | string (256) | ✅ | - | unique |
| `location` | point | ✅ | - | - |
| `city` | string (100) | ❌ | "Peshawar" | key |
| `isActive` | boolean | ❌ | true | key |

### Schools Data Seeded

32 Peshawar schools inserted from `assets/json/schools.json`:
- Peshawar Grammar School, City School, Beacon House, etc.
- All with `isActive: true`, `city: "Peshawar"`

### SchoolsLoader Updated

| Feature | Description |
|---------|-------------|
| **File** | `lib/utils/schools_loader.dart` |
| **Primary** | Fetch from Appwrite TablesDB (only) |
| **Fallback** | None - throws if Appwrite fails |
| **Cache** | 1 hour validity |
| **Query** | `Query.equal('isActive', true)` |
| **New Methods** | `getById(id)`, `getByIds(ids)` |

### Impact on Models (Updated Dec 3)

| Model | Field | Status |
|-------|-------|--------|
| `ServiceDetails` | `schoolIds` | ✅ Primary (FK array) |
| `ServiceDetails` | `schoolNames` | ❌ Removed |
| `ServiceDetails` | `schoolPoints` | ❌ Removed |
| `ChildModel` | `schoolId` | ✅ Primary (FK) |
| `ChildModel` | `schoolName` | ⚠️ Deprecated (display only) |
| `ChildModel` | `schoolLocation` | ⚠️ Deprecated |
| `DriverService` | `schoolIds` | ✅ Primary (FK array) |
| `DriverService` | `schoolNames` | ❌ Removed |

### Database Constants

```dart
// lib/services/appwrite/database_constants.dart
class Collections {
  static const String schools = 'schools'; // NEW
  // ... 17 other collections
}
```

---

## 🚗 Phase 3: Driver Registration - Model Alignment (December 2, 2025)

### Driver Models Updated

All driver registration models have been aligned with Appwrite schema to use URL fields instead of local file paths for storage references.

#### PersonalInfo Model

| Field | Local (Form) | Appwrite Column | Notes |
|-------|--------------|-----------------|-------|
| `firstName` | ✅ | `firstName` | |
| `surName` | ✅ | `surname` | Lowercase in Appwrite |
| `lastName` | ✅ | `lastName` | |
| `phone` | ✅ | `phone` | |
| `photoPath` | Local only | - | For form capture |
| `profilePhotoUrl` | - | `profilePhotoUrl` | URL type |

#### DriverIdentification Model

| Field | Local (Form) | Appwrite Column | Notes |
|-------|--------------|-----------------|-------|
| `cnicNumber` | ✅ | `cnicNumber` | |
| `cnicExpiry` | ✅ (DD-MM-YYYY) | `cnicExpiry` | Datetime type, ISO 8601 |
| `idFrontPhotoPath` | Local only | - | For form capture |
| `idBackPhotoPath` | Local only | - | For form capture |
| `cnicFrontUrl` | - | `cnicFrontUrl` | URL type |
| `cnicBackUrl` | - | `cnicBackUrl` | URL type |

#### DriverLicence Model

| Field | Local (Form) | Appwrite Column | Notes |
|-------|--------------|-----------------|-------|
| `licenceNumber` | ✅ | `licenseNumber` | American spelling in Appwrite |
| `licenseExpiry` | ✅ (DD-MM-YYYY) | `licenseExpiry` | Datetime type, ISO 8601 |
| `licencePhotoPath` | Local only | - | For form capture |
| `selfieWithLicencePath` | Local only | - | For form capture |
| `licensePhotoUrl` | - | `licensePhotoUrl` | URL type |
| `selfieWithLicenseUrl` | - | `selfieWithLicenseUrl` | URL type |

#### VehicleRegistration Model

| Field | Local (Form) | Appwrite Column | Notes |
|-------|--------------|-----------------|-------|
| `vehicleType` | ✅ | `vehicleType` | Enum: car, rikshaw |
| `brand` | ✅ | `brand` | |
| `model` | ✅ | `model` | |
| `color` | ✅ | `color` | |
| `productionYear` | ✅ | `productionYear` | |
| `numberPlate` | ✅ | `numberPlate` | |
| `seatCapacity` | ✅ | `seatCapacity` | |
| `vehiclePhotoPath` | Local only | - | For form capture |
| `certificateFrontPath` | Local only | - | For form capture |
| `certificateBackPath` | Local only | - | For form capture |
| `vehiclePhotoUrl` | - | `vehiclePhotoUrl` | URL type |
| `registrationFrontUrl` | - | `registrationFrontUrl` | URL type |
| `registrationBackUrl` | - | `registrationBackUrl` | URL type |
| `isActive` | ✅ | `isActive` | Default true |

#### ServiceDetails Model

| Field | Local (Form) | Appwrite Column | Notes |
|-------|--------------|-----------------|-------|
| `schoolNames` | ✅ | `schoolNames` | String array |
| `schoolPoints` | Local only | - | No point[] in Appwrite |
| `serviceCategory` | ✅ | `serviceCategory` | Enum: Male, Female, Both |
| `serviceAreaCenter` | ✅ | `serviceAreaCenter` | Point type [lng, lat] |
| `serviceAreaRadiusKm` | ✅ | `serviceAreaRadiusKm` | Double 0.2-10 |
| `serviceAreaPolygon` | ✅ | `serviceAreaPolygon` | Polygon type |
| `serviceAreaAddress` | ✅ | `serviceAreaAddress` | Optional |
| `monthlyPricePkr` | ✅ | `monthlyPricePkr` | Integer |
| `extraNotes` | ✅ | `extraNotes` | Optional |

### New Unified Models Created

| Model | File | Purpose |
|-------|------|---------|
| `Driver` | `lib/models/driver.dart` | Read driver data from Appwrite `drivers` table |
| `Vehicle` | `lib/models/vehicle.dart` | Read vehicle data from Appwrite `vehicles` table |
| `DriverService` | `lib/models/driver_service.dart` | Read service data from Appwrite `driver_services` table |

### Controllers Updated

| Controller | Changes |
|------------|---------|
| `driver_identification_controller.dart` | `expiryDate` → `cnicExpiry`, added backward compatibility |
| `driver_licence_controller.dart` | `expiryDate` → `licenseExpiry`, added backward compatibility |

### toAppwriteJson() Method

All registration models now have `toAppwriteJson()` method that:
- Excludes local file paths (e.g., `photoPath`, `idFrontPhotoPath`)
- Includes only Appwrite-compatible fields
- Uses correct Appwrite column names (e.g., `surname` not `surName`)
- Converts dates to ISO 8601 format

---

## 🔄 TablesDB Migration (December 2, 2025)

### Why Migration Was Needed
Appwrite deprecated the `Databases` class methods:
```
'getDocument' is deprecated. Please use TablesDB.getRow instead.
'listDocuments' is deprecated. Please use TablesDB.listRows instead.
'createDocument' is deprecated. Please use TablesDB.createRow instead.
'updateDocument' is deprecated. Please use TablesDB.updateRow instead.
'deleteDocument' is deprecated. Please use TablesDB.deleteRow instead.
```

### API Changes Summary

| Old (Databases) | New (TablesDB) |
|-----------------|----------------|
| `databases.createDocument()` | `tablesDB.createRow()` |
| `databases.getDocument()` | `tablesDB.getRow()` |
| `databases.listDocuments()` | `tablesDB.listRows()` |
| `databases.updateDocument()` | `tablesDB.updateRow()` |
| `databases.deleteDocument()` | `tablesDB.deleteRow()` |
| `collectionId` | `tableId` |
| `documentId` | `rowId` |
| `DocumentList.documents` | `RowList.rows` |

### Files Updated

| File | Methods Updated |
|------|-----------------|
| `appwrite_client.dart` | Added `tablesDBService()` helper |
| `auth_service.dart` | `_checkUserInDatabase()`, `registerUser()` |
| `parent_service.dart` | `createParent()`, `getParent()`, `getParentById()`, `updateParent()`, `updateProfilePhoto()`, `deleteParent()` |
| `child_service.dart` | `addChild()`, `getChildren()`, `getChild()`, `updateChild()`, `updateChildPhoto()`, `deleteChild()` |

---

## ⚠️ Account Update & Delete Limitations

### Email Update - DISABLED IN UI

Appwrite's `account.updateEmail()` requires the user's **current password**:
```dart
// Requires password - not feasible without password input
await account.updateEmail(email: newEmail, password: userPassword);
```

**Current Behavior:**
- Email update is commented out/disabled in UI
- Name and Phone updates work fine

### Profile Update Flow (Working)

```
updateParent(fullName, phone, email?) → syncs to appropriate places:
├── 1. Account.updateName(name) ✅ - Updates Appwrite account display name
├── 2. Parents table.updateRow() ✅ - Updates fullName, phone in parents table
├── 3. (Optional) Users table.updateRow() ✅ - Updates email in users table (if changed)
│
Note: Phone is stored ONLY in parents/drivers tables (not in users table)
```

**Schema Simplification (Dec 3, 2025):**
- `phone` removed from `users` table - now stored only in `parents`/`drivers` tables
- `isApproved` removed from `users` table - use `status` field instead (active/pending/etc.)

### Delete Account Flow - INCOMPLETE ⚠️

**Current Implementation:**
```
deleteAccount() in settings_controller.dart:
├── 1. ChildService.deleteAllChildren(parentId) ✅ - Deletes all children rows
├── 2. ParentService.deleteParent(parentId) ✅ - Deletes parent row + photo
├── 3. AuthService.logout() ❌ - Only deletes session, NOT account
└── 4. LocalStorage.clearAllUserData() ✅ - Clears local storage
```

**What's Missing:**

| Data Location | Status | Action Needed |
|---------------|--------|---------------|
| `children` table | ✅ Deleted | `deleteAllChildren()` |
| `parents` table | ✅ Deleted | `deleteParent()` |
| `users` table | ❌ **NOT Deleted** | Need `tablesDB.deleteRow(tableId: 'users', rowId: authUserId)` |
| Account (Auth) | ❌ **NOT Deleted** | Client SDK **cannot** delete accounts! |

**Appwrite Account Deletion Limitation:**
- Client SDK can only **block** accounts via `account.updateStatus()`
- **Full account deletion requires Server SDK** with API key
- Server SDK is NOT available in Flutter client apps

**Recommended Solutions:**
1. **Create Appwrite Function** - Server-side function with API key to delete users
2. **Block + Delete Data** - Block account, delete all table data, orphaned account stays
3. **Admin Cleanup** - Periodically delete blocked accounts via Appwrite Console

---

## ⚠️ IMPORTANT: Document ID Strategy

### The `authUserId` Lesson Learned (Dec 2, 2025)

**Problem Encountered:**
- Initially tried to add `authUserId` column to `users` table for linking
- Schema didn't have this column → Query failed: `Attribute not found: authUserId`

**Solution Implemented:**
- **Use Auth User ID as Document ID** for the `users` collection
- This makes lookup efficient: `getDocument(documentId: authUserId)` instead of query
- The document `$id` IS the Auth user ID - no need for a separate column!

### ID Strategy for All Collections

| Collection | Document ID Strategy | Foreign Keys |
|------------|---------------------|--------------|
| `users` | **Auth User ID** (use authUserId as documentId) | - |
| `parents` | Auto-generated (`ID.unique()`) | `userId` → users.$id |
| `children` | Auto-generated (`ID.unique()`) | `parentId` → parents.$id |
| `drivers` | Auto-generated (`ID.unique()`) | `userId` → users.$id |
| `vehicles` | Auto-generated (`ID.unique()`) | `driverId` → drivers.$id |
| `driver_services` | Auto-generated (`ID.unique()`) | `driverId` → drivers.$id |
| `service_requests` | Auto-generated (`ID.unique()`) | `parentId`, `driverId`, `childId` |
| `active_services` | Auto-generated (`ID.unique()`) | `parentId`, `driverId`, `childId` |
| `trips` | Auto-generated (`ID.unique()`) | `activeServiceId`, `driverId`, `childId`, `parentId` |
| `chat_rooms` | Auto-generated (`ID.unique()`) | `parentId`, `driverId` |
| `messages` | Auto-generated (`ID.unique()`) | `chatRoomId`, `senderId` |
| `notifications` | Auto-generated (`ID.unique()`) | `userId` |
| `reports` | Auto-generated (`ID.unique()`) | `reporterId`, `reportedUserId` |
| `geofence_events` | Auto-generated (`ID.unique()`) | `tripId`, `driverId` |
| `ratings` | Auto-generated (`ID.unique()`) | `parentId`, `driverId`, `tripId` |

### Key Points:
1. **users.$id = Auth User ID** - Set explicitly when creating user document
2. **Other foreign keys** (`parentId`, `driverId`, etc.) reference the `$id` of related documents
3. **Relationship columns** in Appwrite also exist (e.g., `parentProfile`, `driverProfile`) - these are for Appwrite's relationship feature
4. **Query by $id** is more efficient than querying by a custom column

---

## 🗄️ Database Collections (17 Total)

### Core Collections

| # | Collection ID | Purpose | Relationships |
|---|---------------|---------|---------------|
| 1 | `users` | Auth user reference | → parents, drivers |
| 2 | `parents` | Parent profiles | → users, children, active_services |
| 3 | `drivers` | Driver profiles | → users, vehicles, active_services |
| 4 | `children` | Child records | → parents, schools |
| 5 | `schools` | School locations | ← children, drivers |
| 6 | `vehicles` | Driver vehicles | → drivers |

### Service & Trip Collections

| # | Collection ID | Purpose | Relationships |
|---|---------------|---------|---------------|
| 7 | `service_requests` | Parent→Driver requests | → parents, drivers, children |
| 8 | `active_services` | Ongoing services | → parents, drivers, children |
| 9 | `trips` | Daily pickup/dropoff | → active_services, children |
| 10 | `trip_history` | Archived trips | Standalone (archived data) |

### Communication Collections

| # | Collection ID | Purpose | Relationships |
|---|---------------|---------|---------------|
| 11 | `chat_rooms` | Chat conversations | → parents, drivers |
| 12 | `messages` | Chat messages | → chat_rooms |
| 13 | `notifications` | Push notifications | → users |

### Support & Analytics Collections

| # | Collection ID | Purpose | Relationships |
|---|---------------|---------|---------------|
| 14 | `reports` | Issue reports | → users (reporter/reported) |
| 15 | `geofences` | Location boundaries | → children, schools |
| 16 | `daily_analytics` | Daily metrics | Standalone |
| 17 | `ratings` | Driver ratings/reviews | → parents, drivers, active_services |

---

## 📦 Storage Buckets (6 Total)

| Bucket ID | Purpose | Max Size | Permissions |
|-----------|---------|----------|-------------|
| `profile_photos` | Parent & driver profile photos | 5MB | ✅ users CRUD |
| `documents` | CNIC, License, Registration docs | 10MB | ✅ users CRUD |
| `vehicle_photos` | Vehicle images | 10MB | ✅ users CRUD |
| `child_photos` | Children's photos | 5MB | ✅ users CRUD |
| `chat_attachments` | Chat image attachments | 5MB | ✅ users CRUD |
| `report_attachments` | Report evidence files | 10MB | ✅ users CRUD |

---

## 🔧 Services Directory

### Appwrite Services (`lib/services/appwrite/`)

| Service | Status | Purpose |
|---------|--------|---------|
| `appwrite_client.dart` | ✅ Complete | Singleton client, Account, Databases, Storage |
| `auth_service.dart` | ✅ Complete | Email OTP, session management, user registration |
| `database_constants.dart` | ✅ Complete | Collection IDs, Bucket IDs, Enums |
| `storage_service.dart` | ✅ Complete | File upload/download with image compression |
| `parent_service.dart` | ✅ Complete | Parent profile CRUD |
| `child_service.dart` | ✅ Complete | Children CRUD |
| `realtime_service.dart` | 🔴 Pending | Realtime subscriptions |
| `functions_service.dart` | 🔴 Pending | Appwrite functions execution |

### StorageService Methods

| Method | Purpose |
|--------|---------|
| `uploadFile(bucketId, file, fileName)` | Upload any file |
| `uploadImage(bucketId, file, fileName)` | Upload with compression (max 1MB) |
| `downloadFile(bucketId, fileId)` | Download file bytes |
| `getImagePreview(bucketId, fileId, width, height)` | Get resized image preview |
| `getFileViewUrl(bucketId, fileId)` | Get direct file URL |
| `deleteFile(bucketId, fileId)` | Delete file |
| `replaceFile(bucketId, oldFileId, newFile)` | Replace existing file |

### ParentService Methods

| Method | Purpose |
|--------|---------|
| `createParent(profile, photo?)` | Create parent profile |
| `getParent(userId?)` | Get parent by user ID |
| `getParentById(parentId)` | Get parent by document ID |
| `updateParent(parentId, fields...)` | Update parent info |
| `updateProfilePhoto(parentId, photo)` | Update profile photo |
| `deleteParent(parentId)` | Delete parent and photo |

### ChildService Methods

| Method | Purpose |
|--------|---------|
| `addChild(parentId, child, photo?)` | Add single child |
| `addChildren(parentId, children, photos?)` | Batch add children |
| `getChildren(parentId?)` | Get all children for parent |
| `getChild(childId)` | Get single child |
| `updateChild(childId, fields...)` | Update child info |
| `updateChildPhoto(childId, photo)` | Update child photo |
| `deleteChild(childId)` | Delete child and photo |
| `deleteAllChildren(parentId)` | Delete all children for parent |

---

## 📨 Messaging Topics (6 Total)

| Topic ID | Purpose |
|----------|---------|
| `all_parents` | Broadcast to all parents |
| `all_drivers` | Broadcast to all drivers |
| `trip_notifications` | Trip status updates |
| `service_requests` | Service request alerts |
| `system_announcements` | System-wide announcements |
| `geofence_alerts` | Geofence entry/exit alerts |

---

## 🔐 Authentication Implementation

### Files Created

| File | Purpose |
|------|---------|
| `lib/services/appwrite/appwrite_client.dart` | Singleton Appwrite client |
| `lib/services/appwrite/auth_service.dart` | Email OTP authentication |
| `lib/services/appwrite/database_constants.dart` | Collection/Bucket IDs & Enums |

### AuthService Methods

| Method | Purpose |
|--------|---------|
| `sendEmailOTP(email)` | Send OTP to email address |
| `verifyEmailOTP(otp)` | Verify OTP and create session |
| `checkSession()` | Check for existing session on app start |
| `logout()` | Delete current session |
| `logoutAll()` | Delete all sessions (all devices) |
| `registerUser(role, name, email, phone?)` | Create user in database |

### AuthResult Fields

```dart
class AuthResult {
  final bool success;
  final String message;
  final String? userId;
  final String? email;
  final bool? isNewUser;      // true = needs registration
  final String? userRole;      // 'parent' | 'driver'
  final String? verificationStatus; // Driver: pending/approved/rejected/suspended
}
```

### Session Persistence

Appwrite SDK **automatically persists sessions** - no manual token storage needed. On app restart:
1. `checkSession()` retrieves persisted session
2. If valid → auto-login with role-based routing
3. If invalid → show login screen

---

## 🎨 UI Integration

### Updated Controllers

| Controller | Changes |
|------------|---------|
| `EmailController` | Calls `AuthService.sendEmailOTP()` with loading/error states |
| `OtpController` | Calls `AuthService.verifyEmailOTP()` with role-based routing |
| `SplashController` | Checks first-time user & session on app start |

### Updated Screens

| Screen | Changes |
|--------|---------|
| `email_screen.dart` | Loading spinner, error snackbar on OTP send |
| `otp_screen.dart` | Loading state, error dialog on verification |
| `onboard_page.dart` | Saves `hasSeenOnboarding` flag on completion |

### New Screens

| Screen | Route | Purpose |
|--------|-------|---------|
| `SplashScreen` | `/` (root) | App entry, checks session & first-time |

---

## 🚀 App Startup Flow

```
App Launch
    ↓
SplashScreen (/)
    ↓
┌─────────────────────────────────────┐
│ Check hasSeenOnboarding in prefs    │
└─────────────────────────────────────┘
    ↓ No                    ↓ Yes
Onboarding          Check Session (Appwrite)
    ↓                       ↓
Set hasSeenOnboarding   ┌───────────────┐
    ↓                   │ Session Valid │
Option Screen           └───────────────┘
                            ↓ No         ↓ Yes
                      Option Screen   Check Role in DB
                                          ↓
                        ┌─────────────────┴─────────────────┐
                        ↓                                   ↓
                   role == 'parent'                  role == 'driver'
                        ↓                                   ↓
                  Parent Map Screen            Check verificationStatus
                                                    ↓
                        ┌───────────────────────────┼───────────────────────────┐
                        ↓                           ↓                           ↓
                   'approved'                  'pending'              'rejected'/'suspended'
                        ↓                           ↓                           ↓
                  Driver Map              Pending Approval             Status Screen
```

---

## 📂 Storage Keys (SharedPreferences)

| Key | Purpose |
|-----|---------|
| `has_seen_onboarding` | Track if user completed onboarding |
| `user_role` | Store user's role (driver/parent) |
| `driver_name` | Driver name during registration |
| `parent_name` | Parent name during registration |
| `driver_email` | Driver's verified email |
| `parent_email` | Parent's verified email |
| `driver_phone` | Driver's phone number |
| `parent_phone` | Parent's phone number |
| `children_list` | JSON list of children (parent side) |
| `personal_info` | Driver personal info JSON |
| `driver_licence` | Driver license info JSON |
| `driver_identification` | Driver ID/CNIC info JSON |
| `vehicle_selection` | Selected vehicle type |
| `vehicle_registration` | Vehicle registration JSON |
| `driver_service_details` | Service area/pricing JSON |

---

## 🔄 Relationship Summary (24 Total)

### Two-Way Relationships

| Collection A | Collection B | Type |
|--------------|--------------|------|
| users | parents | One-to-One |
| users | drivers | One-to-One |
| parents | children | One-to-Many |
| drivers | vehicles | One-to-Many |
| parents | active_services | One-to-Many |
| drivers | active_services | One-to-Many |
| children | active_services | One-to-Many |
| parents | chat_rooms | One-to-Many |
| drivers | chat_rooms | One-to-Many |
| chat_rooms | messages | One-to-Many |
| active_services | trips | One-to-Many |
| parents | ratings | One-to-Many |
| drivers | ratings | One-to-Many |

### Unique Constraints

| Collection | Index | Fields |
|------------|-------|--------|
| chat_rooms | `unique_parent_driver` | parentId + driverId (composite unique) |

---

## 📋 Enum Values

### User Roles
- `parent` | `driver` | `admin`

### Driver Verification Status
- `pending` | `approved` | `rejected` | `suspended`

### Vehicle Types
- `car` | `rickshaw`

### Service Request Status
- `pending` | `accepted` | `rejected` | `expired` | `cancelled`

### Active Service Status
- `active` | `paused` | `terminated`

### Trip Status
- `scheduled` | `enroute` | `arrived` | `picked` | `in_transit` | `dropped` | `absent` | `cancelled`

### Trip Direction
- `home_to_school` | `school_to_home`

---

## 🛠️ Pending Implementation

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Storage Service | ✅ Done | Complete | File upload with image compression |
| Parent Service | ✅ Done | Complete | CRUD operations |
| Child Service | ✅ Done | Complete | CRUD operations |
| Collection Permissions | ✅ Done | Complete | All 17 collections updated |
| Bucket Permissions | ✅ Done | Complete | All 6 buckets updated |
| Driver Service | High | 🔴 Pending | Driver profile CRUD |
| Vehicle Service | High | 🔴 Pending | Vehicle CRUD |
| Realtime Subscriptions | Medium | 🔴 Pending | Live location, chat |
| Push Notifications | Medium | 🔴 Pending | FCM integration |
| Appwrite Functions (CRON) | Medium | 🔴 Pending | Trip generation, analytics |

---

## 📝 Session Notes

### December 2, 2025 - Phase 2: Parent Registration Complete

**Completed:**
1. Created `storage_service.dart` with image compression
2. Created `parent_service.dart` for parent CRUD
3. Created `child_service.dart` for children CRUD
4. Updated `ParentNameController` with `registerParent()` method
5. Updated `AddChildrenController` with sync methods
6. Fixed `authUserId` issue - now using Auth ID as document ID for users
7. Updated all 17 collection permissions to allow user CRUD
8. Updated all 6 storage bucket permissions

**Bug Fix - authUserId:**
- Problem: Tried to query `authUserId` column which didn't exist in schema
- Solution: Use Auth User ID as the document ID for `users` collection
- Code: `documentId: authUserId` instead of `documentId: ID.unique()`
- Lookup: `getDocument(documentId: authUserId)` instead of query

**Test Results:**
```
✅ Session restored for: rayonixsolutions@gmail.com
👤 New user - no record in database
✅ User document created: 692de0dcbbd08863baf4
✅ Parent profile created: 692de3906daa2c918ee8
✅ Parent registered in users collection
✅ Loaded 0 children for parent: 692de3906daa2c918ee8
📝 Child added to local draft
```

### December 1, 2025 - Phase 1: Auth & UI Integration

**Completed:**
1. Created `database_constants.dart` with all collection/bucket IDs
2. Created `auth_service.dart` with Email OTP flow
3. Updated `EmailController` to use AuthService
4. Updated `OtpController` with role-based navigation
5. Created `SplashScreen` for first-time user check
6. Added `hasSeenOnboarding` and `userRole` to StorageKeys
7. Updated `main.dart` to use splash as initial route
8. Updated onboarding to save completion flag

**Session Token Note:**
Appwrite SDK handles session persistence automatically. No need to manually store tokens in SharedPreferences. The `checkSession()` method retrieves persisted sessions on app restart.

---

### June 15, 2025 - Phase 3: Image Caching & Profile Sync

**Completed:**

1. **CachedNetworkImage Implementation**
   - Added `cached_network_image: ^3.4.1` package
   - Updated 7 files to use CachedNetworkImage instead of Image.network/NetworkImage:
     - `child_photo_picker.dart` - Child photo display in registration
     - `profile_avatar.dart` - Profile photo with loading spinner
     - `profile_tile.dart` - Drawer profile display
     - `child_tile_avatar.dart` - Child tiles on parent side
     - `driver_request_tile.dart` - Parent avatar on driver side
     - `driver_order_tile.dart` - Parent avatar on driver side
     - `driver_review_dialog.dart` - Driver photo in review popup

2. **Profile Edit Sync with Appwrite**
   - `edit_name_screen.dart` - Uses `ParentProfileController.updateName()`
   - `edit_phone_screen.dart` - Uses `ParentProfileController.updatePhone()` 
   - `edit_email_screen.dart` - Uses `ParentProfileController.updateEmail()` ⚠️ COMMENTED OUT (issue with email update)
   - Enhanced `ParentProfileController.updatePhone()` to sync with Appwrite (was local only)

3. **Settings Screen Actions**
   - Implemented `_logout()` method:
     - Calls `AuthService.logout()` 
     - Clears local SharedPreferences
     - Navigates to onboarding/option screen
   - Implemented `_deleteAccount()` method:
     - Shows loading dialog during deletion
     - Calls `ChildService.deleteAllChildren()` to remove all children
     - Calls `ParentService.deleteParent()` to remove parent profile
     - Logs out user and clears local data
   - Added `_showDeleteConfirmation()` dialog for safety

**⚠️ Known Issue:**
- Email update functionality is commented out due to issues with Appwrite email verification flow
- Users cannot currently update their email address

**Files Modified:**
```
lib/features/parentSide/parentProfile/widgets/child_photo_picker.dart
lib/features/parentSide/parentProfile/widgets/profile_avatar.dart
lib/features/parentSide/parentProfile/widgets/profile_tile.dart
lib/features/parentSide/children/widgets/child_tile_avatar.dart
lib/features/driverSide/driverHome/widgets/driver_request_tile.dart
lib/features/driverSide/driverHome/widgets/driver_order_tile.dart
lib/features/driverSide/driverHome/widgets/driver_review_dialog.dart
lib/features/parentSide/parentProfile/views/edit_name_screen.dart
lib/features/parentSide/parentProfile/views/edit_email_screen.dart
lib/features/parentSide/parentProfile/views/edit_phone_screen.dart
lib/features/parentSide/parentProfile/controllers/parent_profile_controller.dart
lib/features/parentSide/settings/views/settings_screen.dart
```

**URL Pattern for Appwrite Images:**
```
https://fra.cloud.appwrite.io/v1/storage/buckets/{bucket_id}/files/{file_id}/view?project=68ed397e000f277c6936
```

**Storage Buckets Used:**
- `profile_photos` - Parent profile photos
- `child_photos` - Children's photos
