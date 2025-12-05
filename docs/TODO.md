# 📋 GoDropMe - Backend Development Plan

> **Project**: GoDropMe - School Children Transportation App  
> **Backend**: Appwrite Cloud (fra.cloud.appwrite.io)  
> **Project ID**: `68ed397e000f277c6936`  
> **Created**: November 27, 2025  
> **Last Updated**: December 3, 2025  
> **Status**: Phase 3 Driver Registration ✅ COMPLETE | Driver Auth Flow ✅ COMPLETE | Status Unification ✅ COMPLETE

---

## 🎯 Latest Session: Status Unification & Schema Cleanup (Dec 3, 2025)

### ✅ Unified Status to Users Table Only

Consolidated all user status management to use only the `users` table instead of having duplicate `verificationStatus` in `drivers` table.

#### Schema Changes

| Table | Column | Action | Notes |
|-------|--------|--------|-------|
| `users` | `status` | ✅ KEPT | Single source of truth: `pending`, `active`, `suspended`, `rejected` |
| `users` | `statusReason` | ✅ CREATED | New column (500 chars) - combines suspension & rejection reasons |
| `users` | `suspensionReason` | ❌ DELETED | Merged into `statusReason` |
| `users` | `rejectionReason` | ❌ DELETED | Merged into `statusReason` |
| `drivers` | `verificationStatus` | ❌ DELETED | Now uses `users.status` instead |

#### Why Consolidate to `statusReason`?

A user can only have ONE status at a time - they're either:
- `pending` (no reason needed)
- `active` (no reason needed)
- `suspended` (needs reason → stored in `statusReason`)
- `rejected` (needs reason → stored in `statusReason`)

Since suspended and rejected are mutually exclusive, a single `statusReason` column suffices.

#### Updated Constants

```dart
// lib/services/appwrite/database_constants.dart
class CollectionEnums {
  // User status values (used in users table)
  static const String statusPending = 'pending';
  static const String statusActive = 'active';
  static const String statusSuspended = 'suspended';
  static const String statusRejected = 'rejected';
}
```

#### Files Modified

| File | Changes |
|------|---------|
| `auth_service.dart` | Reads `status` and `statusReason` from users table only |
| `driver_service.dart` | Removed `verificationStatus` writes; uses `CollectionEnums.statusPending` |
| `Driver` model | Removed `verificationStatus` field and `DriverVerificationStatus` enum |
| `splash_controller.dart` | Uses `CollectionEnums.status*` constants; passes `statusReason` to screens |
| `otp_controller.dart` | Same routing logic as splash_controller |
| `database_constants.dart` | Added `statusPending`, `statusActive`, `statusSuspended`, `statusRejected` |

#### Updated Routing Flow

```
Login/Session Check
        ↓
   Check users table
        ↓
   Read status field
        ↓
┌───────┴───────┬───────────┬───────────┐
│               │           │           │
status=active  pending    rejected   suspended
│               │           │           │
▼               ▼           ▼           ▼
Check role   Pending    Rejected    Suspended
│            Screen     Screen      Screen
├─► parent → Parent Map          (with statusReason)
└─► driver → Check hasDriverProfile
               │
     ┌─────────┴─────────┐
     │                   │
   false               true
     │                   │
     ▼                   ▼
Vehicle Selection    Driver Map
(resume registration)
```

#### Key Code Changes

**AuthResult now has single `statusReason`:**
```dart
class AuthResult {
  final String? statusReason; // Used for both suspended and rejected
  // ...
}
```

**Routing uses statusReason for both screens:**
```dart
case CollectionEnums.statusSuspended:
  Get.offAllNamed(AppRoutes.driverSuspended, 
    arguments: {'reason': result.statusReason ?? 'No reason provided'});
  
case CollectionEnums.statusRejected:
  Get.offAllNamed(AppRoutes.driverRejected,
    arguments: {'reason': result.statusReason ?? 'No reason provided'});
```

---

## 🎯 Previous Session: Phase 3 Driver Registration & Auth Flow (Dec 3, 2025)

### ✅ Driver Registration Backend Services Created

Complete backend services for driver registration flow using TablesDB API.

#### Services Created

| Service | File | Purpose | Lines |
|---------|------|---------|-------|
| `DriverService` | `lib/services/appwrite/driver_service.dart` | CRUD for `drivers` table | ~870 |
| `VehicleService` | `lib/services/appwrite/vehicle_service.dart` | CRUD for `vehicles` table | ~539 |
| `DriverConfigService` | `lib/services/appwrite/driver_config_service.dart` | CRUD for `driver_services` table | ~350 |
| `DriverRegistrationService` | `lib/services/appwrite/driver_registration_service.dart` | Orchestrates complete registration | ~500 |

#### Key Implementation Details

**Problem Solved: "Missing required attribute cnicNumber"**
- Appwrite `drivers` table requires ALL fields at creation time
- Cannot create basic profile then update with documents later
- Solution: `createDriverComplete()` method uploads ALL photos and provides ALL required fields in single `createRow()` call

**CNIC Sanitization**
- User input: `17301-4753215-4` (15 chars with dashes)
- Database storage: `1730147532154` (13 digits only)
- Added `_sanitizeCnic()` helper to strip non-digit characters

### ✅ Driver User Registration Flow (Like Parent)

Fixed auth flow so driver users are created in `users` table at name entry (like parents).

#### Flow Comparison

| Step | Parent Flow | Driver Flow (Updated) |
|------|-------------|----------------------|
| 1. OTP Verification | Account created | Account created |
| 2. Name Entry | User created in `users` + `parents` table | User created in `users` table only |
| 3. Registration Complete | ✅ Done | `drivers`, `vehicles`, `driver_services` tables created |

#### Files Modified

| File | Changes |
|------|---------|
| `auth_service.dart` | `registerUser()` only creates `users` row for drivers (not `drivers` row) |
| `driver_name_controller.dart` | Added `registerDriver()` method (calls `AuthService.registerUser`) |
| `driver_name_screen.dart` | Calls `registerDriver()` on submit, shows loading/error states |
| `driverName_action.dart` | Added `isLoading` parameter for button state |

### ✅ Incomplete Registration Resume Flow

If driver user exists in `users` table but NOT in `drivers` table → resume at vehicle selection.

#### Auth Result Enhanced

Added `hasDriverProfile` field to track if driver completed registration:

```dart
class AuthResult {
  // ... existing fields
  final bool hasDriverProfile; // True if driver has profile in drivers table
}
```

#### Files Modified

| File | Changes |
|------|---------|
| `auth_service.dart` | Added `hasDriverProfile` to `_UserCheckResult` and `AuthResult` |
| `splash_controller.dart` | Routes to `/vehicle_selection` if `!hasDriverProfile` |
| `otp_controller.dart` | Same routing logic for post-login |

### ✅ Driver Status Routing

Complete status-based routing for drivers using unified `users.status`:

```
Login/Session Check
        ↓
   Check users table (role = driver)
        ↓
   Read status field (unified)
        ↓
┌───────┴───────┬───────────┬───────────┐
│               │           │           │
status=active  pending    rejected   suspended
│               │           │           │
▼               ▼           ▼           ▼
Check           Pending    Rejected    Suspended
hasDriverProfile Screen    Screen      Screen
│                          (statusReason) (statusReason)
├─► false → Vehicle Selection (resume registration)
└─► true  → Driver Map
```

**Note**: `verificationStatus` was removed from `drivers` table. All status management now uses `users.status` only.

### ✅ Profile Complete Flag

When driver completes full registration, `users` table is updated:

```dart
// In driver_registration_service.dart → _markProfileComplete()
await tablesDB.updateRow(
  tableId: 'users',
  rowId: authUserId,
  data: {'isProfileComplete': true},
);
```

### 📝 Registration Data Flow Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                Driver Registration Flow                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Driver Name Screen                                          │
│     └─► Creates: users table row (role: driver)                 │
│                                                                  │
│  2. Vehicle Selection → Personal Info → CNIC → License →        │
│     Vehicle Details → Service Details                           │
│     └─► All data saved to LOCAL STORAGE                         │
│                                                                  │
│  3. Service Details → Submit Registration                       │
│     └─► DriverRegistrationService.submitRegistration()          │
│         ├─► Upload ALL photos (profile, CNIC×2, license×2)      │
│         ├─► Create drivers row (with ALL required fields)       │
│         ├─► Create vehicles row                                 │
│         ├─► Create driver_services row                          │
│         ├─► Update users.isProfileComplete = true               │
│         └─► Clear local storage                                 │
│                                                                  │
│  4. Navigate to Pending Approval Screen                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Previous Session: Deprecated Fields Cleanup (Dec 3, 2025)

### ✅ Removed All Deprecated Fields

Removed `schoolName`, `schoolLocation`, `schoolNames`, `schoolPoints` from code and Appwrite tables.

### Appwrite Schema (Final)

#### `children` Table

| Column | Type | Notes |
|--------|------|-------|
| `schoolId` | string(36) | FK to schools table ✅ |
| `schoolName` | ❌ **DELETED** | Column removed from Appwrite |
| `schoolLocation` | ❌ **DELETED** | Column removed from Appwrite |

#### `driver_services` Table

| Column | Type | Notes |
|--------|------|-------|
| `schoolIds` | string[](36) | Array of FKs to schools table ✅ |
| `schoolNames` | ❌ **DELETED** | Column removed from Appwrite |

### Code Changes

#### Models Cleaned

| Model | Changes |
|-------|---------|
| `ChildModel` | Removed `schoolName` field completely |
| `ServiceDetails` | Removed legacy `schoolNames` fallback |
| `DriverService` | Removed legacy `schoolNames` fallback |

#### UI Updated

| Component | Change |
|-----------|--------|
| `child_tile.dart` | Looks up school name from `schoolId` using `SchoolsLoader.getById()` |
| `add_child_form.dart` | Only saves `schoolId`, no `schoolName` |
| `add_children_controller.dart` | Removed `_populateSchoolNames()` method |

### Data Flow (Final)

```
┌─────────────────────────────────────────────────────────────────┐
│                 Clean School Architecture                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Appwrite `schools` Table (Source of Truth)                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ id | name | shortName | location | address | city | ... │    │
│  └─────────────────────────────────────────────────────────┘    │
│                          ▲                                       │
│                          │ Lookup by ID                         │
│         ┌────────────────┴────────────────┐                     │
│         │                                 │                     │
│  ┌──────┴──────┐                  ┌──────┴──────┐               │
│  │  children   │                  │driver_services│             │
│  │  (schoolId) │                  │ (schoolIds[]) │             │
│  └─────────────┘                  └───────────────┘             │
│                                                                  │
│  Display: SchoolsLoader.getById() → school.name                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Previous Session: School ID Foreign Keys (Dec 3, 2025)
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ $id (PK)     │ name          │ location [lng,lat]       │    │
│  ├──────────────┼───────────────┼──────────────────────────┤    │
│  │ abc123       │ City School   │ [71.518, 34.035]         │    │
│  │ def456       │ Grammar School│ [71.528, 34.012]         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                          │                                       │
│         ┌────────────────┴────────────────┐                     │
│         ▼                                 ▼                      │
│  Parent Side                       Driver Side                   │
│  ┌──────────────────┐              ┌──────────────────┐          │
│  │ Form: Select     │              │ Form: Select     │          │
│  │ school by name   │              │ schools by name  │          │
│  │                  │              │                  │          │
│  │ Save: schoolId   │              │ Save: schoolIds[]│          │
│  │ (FK to schools)  │              │ (FK array)       │          │
│  └──────────────────┘              └──────────────────┘          │
│           │                                 │                    │
│           ▼                                 ▼                    │
│  children table                    driver_services table         │
│  ┌──────────────────┐              ┌──────────────────┐          │
│  │ schoolId: abc123 │              │ schoolIds:       │          │
│  │                  │              │ [abc123, def456] │          │
│  └──────────────────┘              └──────────────────┘          │
│           │                                 │                    │
│           └─────────────┬───────────────────┘                    │
│                         ▼                                        │
│              SchoolsLoader.getById(s)                            │
│              (Lookup names/coords when displaying)               │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow Summary

| Operation | Data Saved | How Names Displayed |
|-----------|------------|---------------------|
| Add Child | `schoolId` | `SchoolsLoader.getById()` |
| Driver Service Details | `schoolIds[]` | `SchoolsLoader.getByIds()` |
| Children List | Read `schoolId` | Controller populates `schoolName` |
| Driver Profile | Read `schoolIds` | Screen fetches school names |

### Benefits

1. **Data Integrity**: School name changes in one place (schools table)
2. **Referential Integrity**: IDs are stable, names can change
3. **Reduced Storage**: One name per school, not duplicated everywhere
4. **Easier Queries**: Can join/filter by school ID

---

## 🎯 Previous Session: Schools Backend & schoolPoints Resolution (Dec 3, 2025)

### ✅ Schools Table Created in Appwrite

Resolved the `schoolPoints` issue - Appwrite doesn't support `point[]` (array of points). Created a central `schools` table for lookup.

| Table | Columns | Purpose |
|-------|---------|---------|
| `schools` | name, location, city, isActive | Central source of truth for school coordinates |

#### Schools Table Schema

| Column | Type | Required | Default | Notes |
|--------|------|----------|---------|-------|
| `name` | string (256) | ✅ | - | Unique index |
| `location` | point | ✅ | - | [lng, lat] format |
| `city` | string (100) | ❌ | "Peshawar" | Key index |
| `isActive` | boolean | ❌ | true | Key index |

#### Indexes Created

| Index | Type | Column |
|-------|------|--------|
| `idx_name` | unique | name |
| `idx_city` | key | city |
| `idx_isActive` | key | isActive |

### ✅ 32 Schools Seeded from JSON

All schools from `assets/json/schools.json` were inserted into Appwrite:
- Schools 1-16: First batch (Peshawar Grammar, City School, etc.)
- Schools 17-32: Second batch (various Peshawar schools)
- All with `city: "Peshawar"`, `isActive: true`

### ✅ SchoolsLoader Updated

Updated `lib/utils/schools_loader.dart` to fetch from Appwrite with JSON fallback:

```dart
// New flow:
1. Check cache validity (1 hour)
2. Try Appwrite: tablesDB.listRows('schools') with Query.equal('isActive', true)
3. Fallback to assets/json/schools.json if Appwrite fails
4. Return cached data
```

### ✅ ServiceDetails Model Updated

Made `schoolPoints` optional since it's not stored in Appwrite:

| Change | Before | After |
|--------|--------|-------|
| `schoolPoints` | `required` | `optional (default: [])` |
| Constructor | `required this.schoolPoints` | `this.schoolPoints = const []` |
| `toJson()` | Always included | Only if not empty |
| `toAppwriteJson()` | Excluded | Still excluded |

### ✅ Database Constants Updated

```dart
// lib/services/appwrite/database_constants.dart
static const String schools = 'schools'; // Added
```

### 🔍 Children Table - schoolLocation Decision

**Kept `schoolLocation` in ChildModel** because:
- Children table has `schoolLocation` as a **single point** (child goes to ONE school)
- Appwrite **supports** single `point` type
- Different from driver_services which needs **array of points** (driver serves multiple schools)

| Model | Field | Appwrite Support | Decision |
|-------|-------|------------------|----------|
| `ChildModel` | `schoolLocation` | ✅ Single point | **KEEP** |
| `ServiceDetails` | `schoolPoints` | ❌ Point array | **OPTIONAL (local only)** |

### 🏗️ Architecture: How Schools Work Now

```
┌─────────────────────────────────────────────────────────────────┐
│                     Schools Architecture                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Appwrite `schools` Table (Source of Truth)                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ name          │ location [lng,lat] │ city     │ isActive│    │
│  ├───────────────┼────────────────────┼──────────┼─────────┤    │
│  │ City School   │ [71.518, 34.035]   │ Peshawar │ true    │    │
│  │ Grammar School│ [71.528, 34.012]   │ Peshawar │ true    │    │
│  └─────────────────────────────────────────────────────────┘    │
│                          │                                       │
│                          ▼                                       │
│  SchoolsLoader (lib/utils/schools_loader.dart)                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 1. Fetch from Appwrite (primary)                        │    │
│  │ 2. Fallback to assets/json/schools.json                 │    │
│  │ 3. Cache for 1 hour                                     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                          │                                       │
│         ┌────────────────┴────────────────┐                     │
│         ▼                                 ▼                      │
│  Parent Side                       Driver Side                   │
│  (Add Child Form)                  (Service Details Form)        │
│  ┌──────────────────┐              ┌──────────────────┐          │
│  │ Select 1 school  │              │ Select N schools │          │
│  │ Store: schoolName│              │ Store: schoolNames│         │
│  │ + schoolLocation │              │ (names only!)    │          │
│  │ (single point ✅)│              │ No schoolPoints  │          │
│  └──────────────────┘              │ in Appwrite      │          │
│           │                        └──────────────────┘          │
│           ▼                                 │                    │
│  children table                             ▼                    │
│  (schoolLocation: point)           driver_services table         │
│                                    (schoolNames: string[])       │
│                                                                  │
│  Driver Matching: By school name + serviceAreaPolygon geo-query  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Previous Session: TablesDB Migration & API Deprecation Fix (Dec 2, 2025)

### ✅ Migrated from Deprecated Databases API to TablesDB API

Appwrite deprecated the `Databases` methods. All service files now use the new `TablesDB` API:

| Old (Deprecated) | New (TablesDB) |
|------------------|----------------|
| `databases.createDocument()` | `tablesDB.createRow()` |
| `databases.getDocument()` | `tablesDB.getRow()` |
| `databases.listDocuments()` | `tablesDB.listRows()` |
| `databases.updateDocument()` | `tablesDB.updateRow()` |
| `databases.deleteDocument()` | `tablesDB.deleteRow()` |
| `collectionId` parameter | `tableId` parameter |
| `documentId` parameter | `rowId` parameter |
| `DocumentList.documents` | `RowList.rows` |

### ✅ Files Updated for TablesDB

| File | Changes |
|------|---------|
| **appwrite_client.dart** | Added `tablesDBService()` helper method |
| **parent_service.dart** | Updated 6 methods to use TablesDB |
| **auth_service.dart** | Updated 5 method calls to use TablesDB |
| **child_service.dart** | Updated 7 methods to use TablesDB |

### ✅ AppwriteImage Widget Created

Created a new widget for authenticated image loading from Appwrite storage:

| Feature | Details |
|---------|---------|
| **Location** | `lib/common_widgets/appwrite_image.dart` |
| **Purpose** | Load images from buckets with `read("users")` permission |
| **Method** | Uses `storage.getFileView()` SDK method for authentication |
| **Caching** | In-memory cache with URL parsing for bucket/file IDs |
| **Files Updated** | 7 UI files now use `AppwriteImage` instead of `CachedNetworkImage` |

### ⚠️ Account Update & Delete Flow - IMPORTANT

#### Email Update Issue (UI DISABLED)
Email update is **disabled in UI** because Appwrite's `account.updateEmail()` requires the user's password:
```dart
// This requires password - not feasible without password field
await account.updateEmail(email: newEmail, password: userPassword);
```

**Current Update Flow (Name/Phone only):**
```
updateParent() syncs to 3 places:
1. Account.updateName() - Updates account display name ✅
2. Users table - Updates phone/email in database ✅
3. Parents table - Updates fullName/phone/email ✅

Email update: DISABLED in UI (requires password)
```

#### Delete Account Flow - INCOMPLETE ⚠️

**Current Implementation (settings_controller.dart):**
```dart
deleteAccount() {
  1. Delete all children (ChildService.deleteAllChildren) ✅
  2. Delete parent profile (ParentService.deleteParent) ✅
  3. Logout (AuthService.logout - only deletes session) ❌
  4. Clear local data ✅
}
```

**What's Missing:**
| Location | Current Status | Required Action |
|----------|----------------|-----------------|
| **Children table** | ✅ Deleted | `deleteAllChildren()` |
| **Parents table** | ✅ Deleted | `deleteParent()` |
| **Users table** | ❌ NOT Deleted | Need to add `deleteRow()` |
| **Account (Auth)** | ❌ NOT Deleted | Client SDK can only block, not delete! |

**Appwrite Account Deletion Limitation:**
- `account.updateStatus()` can only **block** the account (set status to false)
- **Full account deletion requires Server SDK** with API key (not available in client app)
- Options:
  1. Create an Appwrite Function to delete users (requires API key)
  2. Just block the account + delete all data from tables
  3. Admin manually deletes blocked accounts periodically

---

## 🎯 Previous Session: Phone Optional & Driver Review Dialog

### ✅ Phone Number Made Optional (Parents Collection)

Updated the `parents` collection to make phone number optional:

| Change | Details |
|--------|---------|
| **Appwrite Table** | `phone` column: `required: false`, `default: ""` |
| **ParentProfile Model** | `phone` is now `PhoneNumber?` (nullable) |
| **profile_screen.dart** | Updated null check for optional phone |
| **TODO.md** | Schema updated to reflect optional phone |

### ✅ Driver Review Dialog (NEW)

Created a themed dialog for parents to rate and review their driver after 1 month of service.

| Feature | Description |
|---------|-------------|
| **Location** | `lib/shared/widgets/driver_review_dialog.dart` |
| **Theme** | Purple gradient header matching app theme |
| **Rating** | 5-star interactive rating with emoji labels |
| **Review** | Optional text review field (max 500 chars) |
| **Photo** | Driver profile photo with fallback avatar |
| **Badge** | "1 Month of Service 🎉" celebration badge |
| **Actions** | Submit Review / Maybe Later buttons |

**Usage Example:**
```dart
// Show dialog on ParentMap screen after 1 month of service
await DriverReviewDialog.show(
  context: context,
  driverName: 'Muhammad Ali',
  driverPhotoUrl: 'https://example.com/photo.jpg',
  onSubmit: (rating, review) {
    // Save to Appwrite ratings collection
    await databases.createDocument(
      databaseId: 'godropme_db',
      collectionId: 'ratings',
      documentId: ID.unique(),
      data: {
        'driverId': driverId,
        'parentId': parentId,
        'tripId': tripId,  // Optional
        'rating': rating,
        'review': review,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  },
  onSkip: () {
    // Track that user skipped, maybe ask again later
  },
);
```

**Rating Labels:**
| Rating | Emoji Label |
|--------|-------------|
| 1 star | Poor 😞 |
| 2 stars | Fair 😐 |
| 3 stars | Good 🙂 |
| 4 stars | Very Good 😊 |
| 5 stars | Excellent! 🌟 |

---

## 🎯 Previous Session: Driver Status Screens & Auth Flow

### ✅ Driver Pending Approval Screen (NEW)

Created screen shown to drivers after completing registration while awaiting admin review.

| Feature | Description |
|---------|-------------|
| **Location** | `lib/features/DriverSide/driverPendingApproval/pages/driver_pending_approval_screen.dart` |
| **Route** | `/driver_pending_approval` |
| **Icon** | Hourglass (purple theme) |
| **Message** | "Application Under Review - 12-24 hours" |
| **Info Card** | Notification and email update info |
| **Action** | "Got it" button → returns to onboard |

### ✅ Driver Suspended Screen (NEW)

Created screen shown when admin suspends a driver account.

| Feature | Description |
|---------|-------------|
| **Location** | `lib/features/DriverSide/driverSuspended/pages/driver_suspended_screen.dart` |
| **Route** | `/driver_suspended` |
| **Icon** | Block icon (red/accent theme) |
| **Shows** | Suspension reason (from route arguments) |
| **Info Card** | Contact support info |
| **Actions** | "Contact Support" button, "Sign Out" button |

### ✅ Driver Rejected Screen (NEW)

Created screen shown when admin rejects a driver application.

| Feature | Description |
|---------|-------------|
| **Location** | `lib/features/DriverSide/driverRejected/pages/driver_rejected_screen.dart` |
| **Route** | `/driver_rejected` |
| **Icon** | Cancel icon (red/accent theme) |
| **Shows** | Rejection reason with styled card |
| **Info Card** | "What to do next" guidance |
| **Actions** | "Contact Support", "Apply Again" (restarts registration), "Sign Out" |

### ✅ Updated Routes

Added 3 new routes in `routes.dart` and `driver_routes.dart`:

```dart
static const String driverPendingApproval = '/driver_pending_approval';
static const String driverSuspended = '/driver_suspended';
static const String driverRejected = '/driver_rejected';
```

### ✅ Updated Driver Registration Flow

Changed `service_details_screen.dart` to navigate to pending approval screen instead of directly to driver map:

```dart
// Before
Get.offAllNamed(AppRoutes.driverMap);

// After
Get.offAllNamed(AppRoutes.driverPendingApproval);
```

### ✅ Complete Driver Status Flow

```
Driver Registration Complete
         ↓
   Pending Approval (/driver_pending_approval)
         ↓
    Admin Reviews (12-24 hrs)
         ↓
   ┌─────┴─────┐
   ▼           ▼
APPROVED    REJECTED
   ↓           ↓
Driver Map  Rejected Screen (/driver_rejected)
   ↓           ↓
(Active)    Can Re-apply or Contact Support
   ↓
If Suspended Later → Suspended Screen (/driver_suspended)
```

### ✅ Usage Examples

```dart
// After registration completion
Get.offAllNamed(AppRoutes.driverPendingApproval);

// On rejection (with reason)
Get.offAllNamed(AppRoutes.driverRejected, arguments: {
  'reason': 'Blurry license photo. Please re-upload with clear images.',
});

// On suspension (with reason)
Get.offAllNamed(AppRoutes.driverSuspended, arguments: {
  'reason': 'Multiple complaints received from parents.',
});

// On approval
Get.offAllNamed(AppRoutes.driverMap);
```

---

## 🎯 Previous Session: Trip Generation Split & Analytics System

### ✅ Trip Generation Split (Improvement)

**Before**: Single `generate-daily-trips` function at 4:30 AM creating both morning and afternoon trips

**After**: Two separate functions for precise timing:

| Function | CRON Schedule | Purpose |
|----------|---------------|---------|
| `generate-morning-trips` | **5:00 AM PKT** (`0 5 * * *`) | Creates home→school trips |
| `generate-afternoon-trips` | **11:00 AM PKT** (`0 11 * * *`) | Creates school→home trips |

**Benefits:**
- More accurate driver availability tracking
- Allows same-day changes (e.g., child marked absent before afternoon trips created)
- Reduced system load by spreading operations
- Afternoon trips respect morning absence flags

### ✅ Analytics & Trip History Collections (NEW)

Added **2 new collections** for monitoring and reporting:

| Collection | Purpose |
|------------|---------|
| `daily_analytics` | Daily aggregated metrics (trips, completion rates, delays, etc.) |
| `trip_history` | Individual trip records preserved after trips collection cleanup |

### ✅ New Appwrite Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `generate-daily-analytics` | CRON at 11:59 PM | Create daily analytics summary |
| `archive-trip-to-history` | Event on trip update | Archive trip when it reaches terminal state |

### ✅ UI Bug Fixes

| Bug | File | Fix |
|-----|------|-----|
| Parent profile email not loading | `lib/models/parent_profile.dart` | Added email loading in `loadFromLocal()` |
| "My Location" button not working | `lib/shared/bottom_sheets/location_picker/location_picker_sheet.dart` | Reset `_userChangedSelection = false` in `_locateMe()` |

### ✅ Driver Order Tile UX Improvements

**Key Insight**: Morning and Afternoon are **separate trip documents** — no button reset needed!

| Improvement | Description |
|-------------|-------------|
| **Sequential Button Flow** | Pick Up → then Drop Off becomes active (logical order) |
| **Window Filtering** | Controller filters trips by current time window (morning/afternoon) |
| **Direction Indicator** | Visual badge showing "Home → School" or "School → Home" |
| **Window Header** | Screen header shows current active window |
| **Button States** | Green checkmark when action completed, gray when disabled |

**Button Logic:**
```
Scheduled/Enroute/Arrived → [Pick Up ✓] [Drop Off ✗] [Absent ✓]
Picked/InTransit         → [Picked ✓]  [Drop Off ✓] [Absent hidden]
Dropped/Absent/Cancelled → All buttons disabled (finalized)
```

**Files Updated:**
- `driver_order_tile.dart` — Sequential button logic, direction indicator
- `driver_orders_controller.dart` — Window filtering, demo data for both windows
- `driver_orders_screen.dart` — Window header indicator

### ✅ Updated Schema Summary

- **Total Collections**: 17 (was 14, added `daily_analytics` + `trip_history` + `ratings`)
- **Total Functions**: 10 (was 7, added 3 new functions)
- **Codebase Analysis**: `flutter analyze` shows 12 minor info issues (no errors)

---

## 🎯 Previous Session: Comprehensive Codebase Audit & ID Fixes

### ✅ Full Codebase Audit Against Appwrite Schema

Audited **78 files** across the entire codebase to verify alignment with Appwrite schema:

| Category | Files Audited | Status |
|----------|---------------|--------|
| Core Models (`lib/models/`) | 5 files | ✅ Compliant |
| Parent Side Models | 6 files | ✅ Compliant |
| Driver Side Models | 12 files | ✅ Fixed |
| Parent Side UI (pages/widgets) | 18 files | ✅ Verified |
| Driver Side UI (pages/widgets) | 18 files | ✅ Verified |
| Common Features UI | 3 files | ✅ Verified |
| Common/Shared Widgets | 8 files | ✅ Verified |
| Config/Services | 3 files | ✅ Verified |
| Constants | 3 files | ✅ Verified |

### ✅ ID Handling Fixes (Critical)

Appwrite auto-generates `$id`, `$createdAt`, `$updatedAt` for all documents. Fixed models that were missing proper `$id` parsing:

| Model | File | Fix Applied |
|-------|------|-------------|
| **ChildModel** | `lib/features/parentSide/addChildren/models/child.dart` | Added `id` field for `$id`, added `parentId` field for relationship |
| **ChildPickup** | `lib/features/DriverSide/driverHome/models/driver_map.dart` | Fixed `fromJson()` to parse `$id` first |

**ChildModel Changes:**
```dart
// Added fields
final String? id;       // children.$id
final String? parentId; // parents.$id reference

// fromJson now correctly parses:
id: json['\$id']?.toString() ?? json['id']?.toString(),
parentId: json['parentId']?.toString(),
```

### ✅ Documentation Updated

| File | Changes |
|------|---------|
| `docs/CHANGES_TRACKING.md` | Added comprehensive 78-file audit documentation with ID fixes section |
| `docs/TODO.md` | Added "Auto-Generated Fields" section and "ID Handling Pattern" guide |

---

## 🎯 Earlier Session Changes (VehicleType Extraction & Parent Absent)

### ✅ Enum Refactoring

| Change | Details |
|--------|---------|
| **VehicleType enum extracted** | Moved to `lib/models/enums/vehicle_type.dart` for cleaner separation |
| **vehicle_registration.dart** | Now imports and re-exports from the new enum file |
| **Backwards compatibility** | Existing imports via `vehicle_registration.dart` still work |

### ✅ Parent-Side Absent Marking (NEW)

| File | Changes |
|------|---------|
| `add_children_controller.dart` | Added `markAbsentToday()`, `clearAbsent()`, `isAbsentToday()` methods |
| `child_tile_action_buttons.dart` | Added "Mark Absent Today" toggle button with visual state |
| `child_tile.dart` | Added `onMarkAbsent` callback and `isAbsentToday` props |
| `add_children_screen.dart` | Connected absent toggle to controller methods |

### ✅ Driver-Side Absent Button Fix

| File | Changes |
|------|---------|
| `driver_order_tile.dart` | Hide "Mark Absent" button after `picked` status (child already picked up) |

### ✅ Parent Profile UI Enhancement

| File | Changes |
|------|---------|
| `profile_screen.dart` | Added Phone tile (optional field) with stored phone number display |

---

## 🎯 Previous Session Changes (Deep Verification)

### ✅ Models Fully Aligned with Appwrite Schema

| Model | File | Changes |
|-------|------|---------|
| **ChildModel** | `lib/features/parentSide/addChildren/models/child.dart` | Added `photoFileId`, `specialNotes`, `isActive`, `assignedDriverId` |
| **DriverRequest** | `lib/features/DriverSide/driverHome/models/driver_request.dart` | Fully matches `service_requests` schema |
| **DriverOrder** | `lib/features/DriverSide/driverHome/models/driver_order.dart` | Fully matches `trips` schema, all status values |
| **DriverListing** | `lib/features/parentSide/findDrivers/models/driver_listing.dart` | Added `driverId`, `profilePhotoFileId`, `rating`, `totalTrips`, `distanceKm` |
| **ChatMessage (Both)** | Both chat message models | Added `chatRoomId`, `senderId`, `senderRole`, `messageType`, `imageFileId`, `location`, `isRead` |
| **ChatContact (Both)** | Both chat contact models | Added parent/driver ID refs, `lastMessage`, `lastMessageAt`, `unreadCount` |
| **Notifications (Both)** | Both notification models | Added `userId`, `body`, `data`, `isRead`, updated enum values |
| **VehicleRegistration** | `lib/features/DriverSide/driverRegistration/models/vehicle_registration.dart` | Uses `VehicleType` from enum file, Appwrite storage file IDs, `toAppwriteJson()` |
| **ParentProfile** | `lib/models/parent_profile.dart` | Added `id`, `userId`, `email`, `profilePhotoFileId`, `address`, `homeLocation` |

### ✅ Controllers Updated

| Controller | Changes |
|------------|---------|
| `driver_conversation_controller.dart` | Uses `chatRoomId`, `senderId`, `senderRole` |
| `parent_conversation_controller.dart` | Uses `chatRoomId`, `senderId`, `senderRole` |
| `driver_requests_controller.dart` | Updated `fromRequest()` with all new fields |
| `driver_orders_controller.dart` | Added `markAbsent()` method |
| `vehicle_selection_controller.dart` | Uses consolidated `VehicleType` enum |
| `add_children_controller.dart` | Added absent marking methods |

### ✅ UI Updates

| Widget | Changes |
|--------|---------|
| `driver_order_tile.dart` | Added "Mark Absent" button, `onAbsent` callback, `isFinalized` state, hide after `picked` |
| `driver_orders_screen.dart` | Passes `onAbsent` to tile |
| `profile_screen.dart` | Added Phone tile |
| `child_tile.dart` | Added absent props and callback |
| `child_tile_action_buttons.dart` | Added "Mark Absent Today" button |
| `add_children_screen.dart` | Connected absent toggle |

### ✅ Code Consolidation

- Extracted `VehicleType` enum to `lib/models/enums/vehicle_type.dart`
- Removed duplicate from `vehicle_selection.dart`
- Re-exported via `vehicle_registration.dart` for backwards compatibility

---

## 🎯 Earlier Session Changes (November 27-28, 2025)

### ✅ Models Updated for Appwrite Compatibility

| Model | File | Changes |
|-------|------|---------|
| **School** | `lib/models/school.dart` | Added `toJson()` with `[lng, lat]`, `toAppwritePoint()`, `fromAppwritePoint()` |
| **LatLngLite** | `lib/models/value_objects.dart` | Added `toAppwritePoint()`, `fromAppwritePoint()` for `[lng, lat]` format |
| **ChildModel** | `lib/features/parentSide/addChildren/models/child.dart` | Renamed `pickupTime` → `schoolOpenTime`, added `schoolOffTime`, uses `[lng, lat]` |
| **ChildPickup** | `lib/features/DriverSide/driverHome/models/driver_map.dart` | Added `toJson()` |
| **DriverOrder** | `lib/features/DriverSide/driverHome/models/driver_order.dart` | Added `toJson()`, `fromJson()` |
| **DriverRequest** | `lib/features/DriverSide/driverHome/models/driver_request.dart` | Added `toJson()`, `fromJson()` |
| **DriverListing** | `lib/features/parentSide/findDrivers/models/driver_listing.dart` | Added `toJson()`, `fromJson()` |
| **ParentNotificationItem** | `lib/features/parentSide/notifications/models/parent_notification.dart` | Added `toJson()`, `fromJson()` with enum handling |
| **DriverNotificationItem** | `lib/features/DriverSide/notifications/models/driver_notification.dart` | Added `toJson()`, `fromJson()` with enum handling |
| **ChatContact (Parent)** | `lib/features/parentSide/parentChat/models/chat_contact.dart` | Added `toJson()`, `fromJson()` |
| **ChatMessage (Parent)** | `lib/features/parentSide/parentChat/models/chat_message.dart` | Added `toJson()`, `fromJson()` |
| **ChatContact (Driver)** | `lib/features/DriverSide/driverChat/models/chat_contact.dart` | Added `toJson()`, `fromJson()` |
| **ChatMessage (Driver)** | `lib/features/DriverSide/driverChat/models/chat_message.dart` | Added `toJson()`, `fromJson()` |

### ✅ Geo Format Standardization

All location fields now use Appwrite's `point` format: `[longitude, latitude]`

```dart
// Appwrite Point Format
'location': [71.5249, 34.0151]  // [lng, lat] - Peshawar

// Conversion helpers added to LatLngLite
LatLngLite.toAppwritePoint()     // → [lng, lat]
LatLngLite.fromAppwritePoint()   // ← [lng, lat]
```

### ✅ Validation Improvements

| Validator | File | Purpose |
|-----------|------|---------|
| `dateDMYFuture()` | `lib/utils/validators.dart` | Validates DD-MM-YYYY + ensures future date |
| `toIso8601()` | `lib/utils/validators.dart` | Converts DD-MM-YYYY → ISO 8601 for Appwrite datetime |

**Applied to:**
- `lib/features/DriverSide/driverRegistration/widgets/driverLicense/driverlicence_form.dart`
- `lib/features/DriverSide/driverRegistration/widgets/driverIdentification/driver_identification_form.dart`

### ✅ UI/UX Fixes

| Fix | Files | Description |
|-----|-------|-------------|
| **Removed duplicate DateInputFormatter** | `driver_identification_form.dart` | Uses `ExtraInputFormatters.dateDmy` instead |
| **Fixed child tile data display** | `child_tile.dart` | Fixed key mismatches: `schoolName`, `pickPoint`, `dropPoint`, `relationshipToChild` |
| **Disabled map toolbar** | `parent_map_screen.dart`, `driver_map_screen.dart` | Added `mapToolbarEnabled: false` |
| **Fixed double location calls** | Both map screens | Removed from `initState`, kept only in `onMapCreated` |
| **Fixed location picker zoom jitter** | `map_view.dart`, `location_picker_sheet.dart` | Added `userChangedUpstream` flag |
| **Auto-center on current location** | `location_picker_sheet.dart` | Animates to user location when opening picker |

### ✅ Service Details & Pricing

| Change | Files | Description |
|--------|-------|-------------|
| **Added Monthly Price field** | `service_form_items.dart`, `service_details_form.dart` | New "Monthly Service Price (PKR)" text field with validation |
| **Price in DriverListing** | `driver_listing.dart`, `driver_listing_tile.dart` | Added `monthlyPricePkr` field and display with comma formatting |
| **Fixed school points extraction** | `service_details_screen.dart` | Handles both `location: [lng, lat]` and legacy `lat/lng` formats |
| **Fixed polygon format** | `service_details_screen.dart`, `service_details.dart` | Corrected to Appwrite 3D format `[[[lng, lat], ...]]` with closed ring |
| **Updated ServiceDetails model** | `service_details.dart` | Added `monthlyPricePkr`, fixed polygon type to `List<List<List<double>>>` |
| **Removed operatingDays** | Multiple files | Removed from service details (form, model, controller, screen) and find drivers |
| **Driver phone E.164 format** | `personal_info.dart` | Added `phone` field with `phoneE164` getter for Appwrite-compatible format (+92XXXXXXXXXX) |

### ✅ Appwrite Geo Format Corrections

**Point Format** (correct): `[longitude, latitude]`
```dart
'serviceAreaCenter': [71.588, 34.022]  // [lng, lat]
'schoolPoints': [[71.444, 33.996], [71.542, 34.025]]  // Array of points
```

**Polygon Format** (corrected):
```dart
// ❌ Wrong (2D array):
'serviceAreaPolygon': [[71.5, 34.0], [71.6, 34.0], ...]

// ✅ Correct (3D array with closed ring):
'serviceAreaPolygon': [[[71.5, 34.0], [71.6, 34.0], ..., [71.5, 34.0]]]
//                     ^-- outer array holds rings
//                      ^-- first ring (exterior boundary)
//                                                      ^-- ring is closed
```

### ✅ Test Updates

- Updated `test/models/child_model_test.dart` for `schoolOpenTime`/`schoolOffTime` fields

---

## 📊 Project Overview

GoDropMe connects **Parents** seeking safe school transportation with **Drivers** providing this service. The app targets the **Peshawar, Pakistan** region.

### Tech Stack
| Component | Technology |
|-----------|------------|
| **Frontend** | Flutter + GetX (State Management) |
| **Backend** | Appwrite Cloud |
| **Auth** | Appwrite Email OTP |
| **Database** | Appwrite Databases |
| **Storage** | Appwrite Storage |
| **Functions** | Appwrite Functions (Node.js/Dart) |
| **Realtime** | Appwrite Realtime (WebSocket) |
| **Messaging** | Appwrite Messaging (Push Notifications) |
| **Maps** | Google Maps Flutter |
| **Local Storage** | SharedPreferences (for drafts) |

---

## 🔐 Authentication Flow (Email OTP)

Based on [Appwrite Email OTP Documentation](https://appwrite.io/docs/products/auth/email-otp):

### Registration Flow (New Users):
```
1. User on Onboard Screen → taps "Get Started"
   ↓
2. Option Screen → User sees registration options
   ↓
3. Email Screen → User enters email
   ↓
4. account.createEmailToken(userId: ID.unique(), email) → OTP sent
   ↓
5. OTP Screen → User enters 6-digit code
   ↓
6. account.createSession(userId, secret) → Session created
   ↓
7. DOP Option Screen → Choose Parent or Driver role
   ↓
8. Role-specific registration flow begins
```

### Login Flow (Already Registered Users):
```
1. User on Onboard Screen → taps "Already have an account?" / "Sign In"
   ↓
2. Option Screen → User sees login options
   ↓
3. Email Screen → User enters their registered email
   ↓
4. account.createEmailToken(userId: existingUserId, email) → OTP sent
   ↓
5. OTP Screen → User enters 6-digit code
   ↓
6. account.createSession(userId, secret) → Session created
   ↓
7. CHECK USER STATUS in 'users' collection:
   │
   ├─► status == 'active' && role == 'parent' → Parent Map (/map_screen)
   │
   ├─► status == 'active' && role == 'driver' && hasDriverProfile → Driver Map (/driver_map)
   │
   ├─► status == 'active' && role == 'driver' && !hasDriverProfile → Vehicle Selection (resume)
   │
   ├─► status == 'pending' → Pending Approval (/driver_pending_approval)
   │
   ├─► status == 'rejected' → Rejected Screen (/driver_rejected) with statusReason
   │
   └─► status == 'suspended' → Suspended Screen (/driver_suspended) with statusReason
```

### Key Methods:
```dart
// Step 1: Send OTP (works for both new and existing users)
final token = await account.createEmailToken(
  userId: ID.unique(), // For new users
  // OR: userId: existingUserId, // For existing users (looked up by email)
  email: 'user@example.com',
);
final userId = token.userId;

// Step 2: Verify OTP and create session  
final session = await account.createSession(
  userId: userId,
  secret: '123456', // 6-digit OTP from email
);

// Step 3: Check status and redirect (for existing users)
Future<void> handlePostLogin(String userId) async {
  try {
    final userDoc = await tablesDB.getRow(
      databaseId: 'godropme_db',
      tableId: 'users',
      rowId: userId,
    );
    
    final role = userDoc.data['role'];
    final status = userDoc.data['status'];
    final statusReason = userDoc.data['statusReason'];
    
    // Use CollectionEnums constants for type-safe comparison
    switch (status) {
      case CollectionEnums.statusActive:
        if (role == 'parent') {
          Get.offAllNamed(AppRoutes.parentmapScreen);
        } else if (role == 'driver') {
          // Check if driver has profile
          final hasProfile = await _checkDriverProfile(userId);
          if (hasProfile) {
            Get.offAllNamed(AppRoutes.driverMap);
          } else {
            Get.offAllNamed(AppRoutes.vehicleSelection); // Resume registration
          }
        }
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
  } catch (e) {
    // User document not found - new user, go to DOP Option
    Get.offAllNamed(AppRoutes.dopOption);
  }
}
```

### Visual Login Flow:
```
┌─────────────────────────────────────────────────────────────────┐
│                    EXISTING USER LOGIN                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │ Onboard  │───►│  Option  │───►│  Email   │───►│   OTP    │  │
│  │ Screen   │    │  Screen  │    │  Screen  │    │  Screen  │  │
│  └──────────┘    └──────────┘    └──────────┘    └────┬─────┘  │
│                                                        │        │
│                                                        ▼        │
│                                              ┌─────────────────┐│
│                                              │ Check User Role ││
│                                              │ in 'users' DB   ││
│                                              └────────┬────────┘│
│                                                       │         │
│                         ┌─────────────────────────────┼─────────┤
│                         │                             │         │
│                         ▼                             ▼         │
│              ┌────────────────────┐       ┌────────────────────┐│
│              │   role == 'parent' │       │  role == 'driver'  ││
│              └─────────┬──────────┘       └─────────┬──────────┘│
│                        │                            │           │
│                        ▼                            ▼           │
│              ┌────────────────────┐      ┌─────────────────────┐│
│              │   Parent Map       │      │  Check Driver       ││
│              │   (/map_screen)    │      │  Status             ││
│              └────────────────────┘      └──────────┬──────────┘│
│                                                     │           │
│                    ┌────────────────────────────────┼───────────┤
│                    │              │                 │           │
│                    ▼              ▼                 ▼           │
│           ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│           │   Active    │ │  Pending    │ │ Rejected/   │       │
│           │   Driver    │ │  Approval   │ │ Suspended   │       │
│           └──────┬──────┘ └──────┬──────┘ └──────┬──────┘       │
│                  │               │               │              │
│                  ▼               ▼               ▼              │
│           ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│           │ Driver Map  │ │ Pending     │ │ Status      │       │
│           │(/driver_map)│ │ Screen      │ │ Screen      │       │
│           └─────────────┘ └─────────────┘ └─────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Complete App Flow (Registration to Active User)

### User Journey Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           APP LAUNCH                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌───────────┐ │
│   │  Onboard    │ ──► │   Option    │ ──► │   Email     │ ──► │    OTP    │ │
│   │  Screen     │     │   Screen    │     │   Screen    │     │   Screen  │ │
│   └─────────────┘     └─────────────┘     └─────────────┘     └─────┬─────┘ │
│                                                                      │       │
│                                                                      ▼       │
│                                                           ┌─────────────────┐│
│                                                           │  DOP Option     ││
│                                                           │ (Parent/Driver) ││
│                                                           └────────┬────────┘│
│                                                                    │         │
│                          ┌─────────────────────────────────────────┼─────────┤
│                          │                                         │         │
│                          ▼                                         ▼         │
│               ┌─────────────────────┐               ┌────────────────────────┤
│               │    PARENT FLOW      │               │     DRIVER FLOW        │
│               ├─────────────────────┤               ├────────────────────────┤
│               │                     │               │                        │
│               │  ┌───────────────┐  │               │  ┌──────────────────┐  │
│               │  │  Parent Name  │  │               │  │   Driver Name    │  │
│               │  │    Screen     │  │               │  │     Screen       │  │
│               │  └───────┬───────┘  │               │  └────────┬─────────┘  │
│               │          │          │               │           │            │
│               │          ▼          │               │           ▼            │
│               │  ┌───────────────┐  │               │  ┌──────────────────┐  │
│               │  │  Parent Map   │  │               │  │ Vehicle Selection│  │
│               │  │   (Home)      │  │               │  │   (Car/Rikshaw)  │  │
│               │  └───────────────┘  │               │  └────────┬─────────┘  │
│               │                     │               │           │            │
│               │  ✅ REGISTRATION    │               │           ▼            │
│               │     COMPLETE!       │               │  ┌──────────────────┐  │
│               │                     │               │  │  Personal Info   │  │
│               │  Parent can now:    │               │  │  (Name, DOB,     │  │
│               │  • Add children     │               │  │   CNIC, Photo)   │  │
│               │  • Find drivers     │               │  └────────┬─────────┘  │
│               │  • Chat             │               │           │            │
│               │  • Track trips      │               │           ▼            │
│               └─────────────────────┘               │  ┌──────────────────┐  │
│                                                     │  │ Driver Licence   │  │
│                                                     │  │ (License photos) │  │
│                                                     │  └────────┬─────────┘  │
│                                                     │           │            │
│                                                     │           ▼            │
│                                                     │  ┌──────────────────┐  │
│                                                     │  │   Identification │  │
│                                                     │  │  (CNIC photos)   │  │
│                                                     │  └────────┬─────────┘  │
│                                                     │           │            │
│                                                     │           ▼            │
│                                                     │  ┌──────────────────┐  │
│                                                     │  │ Vehicle Reg      │  │
│                                                     │  │ (Vehicle photos, │  │
│                                                     │  │  registration)   │  │
│                                                     │  └────────┬─────────┘  │
│                                                     │           │            │
│                                                     │           ▼            │
│                                                     │  ┌──────────────────┐  │
│                                                     │  │ Service Details  │  │
│                                                     │  │ (Schools, Area,  │  │
│                                                     │  │  Pricing)        │  │
│                                                     │  └────────┬─────────┘  │
│                                                     │           │            │
│                                                     │           ▼            │
│                                                     │  ┌──────────────────┐  │
│                                                     │  │ PENDING APPROVAL │  │
│                                                     │  │                  │  │
│                                                     │  │ "Application     │  │
│                                                     │  │  Under Review"   │  │
│                                                     │  │                  │  │
│                                                     │  │ (12-24 hours)    │  │
│                                                     │  └────────┬─────────┘  │
│                                                     │           │            │
│                                                     │    ┌──────┴──────┐     │
│                                                     │    │   ADMIN     │     │
│                                                     │    │   REVIEW    │     │
│                                                     │    └──────┬──────┘     │
│                                                     │           │            │
│                                                     │     ┌─────┴─────┐      │
│                                                     │     ▼           ▼      │
│                                                     │ ┌────────┐ ┌────────┐  │
│                                                     │ │APPROVED│ │REJECTED│  │
│                                                     │ └───┬────┘ └───┬────┘  │
│                                                     │     │          │       │
│                                                     │     ▼          ▼       │
│                                                     │ ┌────────┐ ┌────────┐  │
│                                                     │ │ Driver │ │ Email/ │  │
│                                                     │ │  Map   │ │ Notif  │  │
│                                                     │ │ (Home) │ │ Reason │  │
│                                                     │ └────────┘ └────────┘  │
│                                                     │     After approval     │
│                                                     │  Driver can now:       │
│                                                     │  • View orders         │
│                                                     │  • Start trips         │
│                                                     │  • Chat with parents   │
│                                                     │  • Track earnings      │
│                                                     └────────────────────────┘
└─────────────────────────────────────────────────────────────────────────────┘
```

### Screen Routes Reference

| Screen | Route | Description |
|--------|-------|-------------|
| Onboard | `/onboard` | Initial app introduction carousel |
| Option | `/option_screen` | "Get Started" / "Sign In" options |
| Email | `/phone_screen` | Email input for OTP |
| OTP | `/otp_screen` | 6-digit verification code |
| DOP Option | `/dop_option` | Choose Parent or Driver |
| **Parent Flow** | | |
| Parent Name | `/parent_name` | Enter parent's name |
| Parent Map | `/map_screen` | Parent home screen (map) |
| **Driver Flow** | | |
| Driver Name | `/driver_name` | Enter driver's name |
| Vehicle Selection | `/vehicle_selection` | Choose Car or Rickshaw |
| Personal Info | `/personal_info` | Name, DOB, CNIC, photo |
| Driver Licence | `/driver_licence` | Licence front/back photos |
| Driver Identification | `/driver_identification` | CNIC front/back photos |
| Vehicle Registration | `/vehicle_registration` | Vehicle details & photos |
| Service Details | `/driver_service_details` | Schools, area, pricing |
| Pending Approval | `/driver_pending_approval` | "Under Review" screen (12-24 hrs) |
| **Driver Status Screens** | | |
| Driver Map | `/driver_map` | Driver home screen (after approval) |
| Driver Rejected | `/driver_rejected` | Application rejected with reason |
| Driver Suspended | `/driver_suspended` | Account suspended with reason |

### Backend Status Handling

```dart
// User status enum in Appwrite (users.status field)
// Use CollectionEnums constants for type-safe comparison
class CollectionEnums {
  static const String statusPending = 'pending';    // Just registered, awaiting approval (drivers)
  static const String statusActive = 'active';      // Approved and can use app
  static const String statusSuspended = 'suspended'; // Temporarily disabled (with statusReason)
  static const String statusRejected = 'rejected';   // Application rejected (with statusReason)
}

// Check user status on app launch
Future<void> checkUserStatus() async {
  final user = await getCurrentUser();
  if (user == null) {
    // Not logged in → optionScreen
    Get.offAllNamed(AppRoutes.optionScreen);
    return;
  }
  
  final userDoc = await tablesDB.getRow(
    databaseId: 'godropme_db',
    tableId: 'users',
    rowId: user.$id,
  );
  
  final role = userDoc.data['role'];
  final status = userDoc.data['status'];
  final statusReason = userDoc.data['statusReason']; // Single field for both suspension/rejection
  
  if (role == 'parent') {
    // Parents don't need approval - go directly to dashboard
    Get.offAllNamed(AppRoutes.parentmapScreen);
  } else if (role == 'driver') {
    switch (status) {
      case CollectionEnums.statusPending:
        // Still waiting for admin approval
        Get.offAllNamed(AppRoutes.driverPendingApproval);
        break;
        
      case CollectionEnums.statusActive:
        // Check if driver completed registration (has profile in drivers table)
        final hasDriverProfile = await _checkDriverProfile(user.$id);
        if (hasDriverProfile) {
          Get.offAllNamed(AppRoutes.driverMap);
        } else {
          Get.offAllNamed(AppRoutes.vehicleSelection); // Resume registration
        }
        break;
        
      case CollectionEnums.statusRejected:
        // Application rejected - show reason and allow re-apply
        Get.offAllNamed(
          AppRoutes.driverRejected,
          arguments: {'reason': statusReason ?? 'No reason provided'},
        );
        break;
        
      case CollectionEnums.statusSuspended:
        // Account suspended - show reason and support contact
        Get.offAllNamed(
          AppRoutes.driverSuspended,
          arguments: {'reason': statusReason ?? 'No reason provided'},
        );
        break;
    }
  }
}
```

### Admin Approval Workflow

**When driver completes registration:**
1. All registration data saved to Appwrite collections
2. `users.status` = `pending`
3. Driver sees "Pending Approval" screen

**Admin reviews application:**
1. Admin dashboard shows pending drivers
2. Admin can view all uploaded documents
3. Admin clicks "Approve" or "Reject"

**On Approval:**
```dart
// Update user status using TablesDB API
await tablesDB.updateRow(
  databaseId: 'godropme_db',
  tableId: 'users',
  rowId: driverId,
  data: {
    'status': CollectionEnums.statusActive, // 'active'
    'statusReason': null, // Clear any previous reason
  },
);

// Send push notification
await sendPushNotification(
  userId: driverId,
  title: 'Application Approved! 🎉',
  body: 'Congratulations! You can now start accepting ride requests.',
);

// Send email notification
await sendEmail(
  to: driverEmail,
  subject: 'GoDropMe - Application Approved',
  body: 'Your driver application has been approved...',
);
```

**On Rejection:**
```dart
// Update user status with statusReason
await tablesDB.updateRow(
  databaseId: 'godropme_db',
  tableId: 'users',
  rowId: driverId,
  data: {
    'status': CollectionEnums.statusRejected, // 'rejected'
    'statusReason': 'Blurry license photo. Please re-upload with clear images.',
  },
);

// Send notification with reason
await sendPushNotification(
  userId: driverId,
  title: 'Application Update',
  body: 'We need more information. Please check your email.',
);

await sendEmail(
  to: driverEmail,
  subject: 'GoDropMe - Application Needs Attention',
  body: 'Reason: Blurry license photo. Please re-upload...',
);
```

**On Suspension (for active drivers):**
```dart
// Update user status with statusReason
await tablesDB.updateRow(
  databaseId: 'godropme_db',
  tableId: 'users',
  rowId: driverId,
  data: {
    'status': CollectionEnums.statusSuspended, // 'suspended'
    'statusReason': 'Multiple complaints received from parents.',
  },
);

// Send notification
await sendPushNotification(
  userId: driverId,
  title: 'Account Suspended',
  body: 'Your account has been temporarily suspended. Contact support for more info.',
);
```

---

## 🗃️ Database Schema (Appwrite Collections)

### Database: `godropme_db`

> **Note**: Appwrite auto-generates `$id`, `$createdAt`, `$updatedAt` for all documents.

### Available Attribute Types in Appwrite:
| Type | Description |
|------|-------------|
| `string` | Text data (max 1,073,741,824 bytes) |
| `integer` | Whole numbers |
| `float` | Decimal numbers |
| `boolean` | true/false |
| `datetime` | ISO 8601 date-time |
| `email` | Validated email format |
| `url` | Validated URL format |
| `ip` | IP address |
| `enum` | Predefined set of values |
| `point` | Geographic point `[longitude, latitude]` |
| `line` | Geographic line (array of points) |
| `polygon` | Geographic polygon (closed shape) |
| `relationship` | Link to another collection |

### ⚠️ Auto-Generated Fields (System Managed)

Appwrite **automatically generates** the following fields for every document:

| Field | Type | Description |
|-------|------|-------------|
| `$id` | string(36) | Unique document ID (auto or custom via `ID.unique()`) |
| `$createdAt` | datetime | ISO 8601 timestamp when document was created |
| `$updatedAt` | datetime | ISO 8601 timestamp when document was last updated |
| `$permissions` | array | Document-level permissions array |
| `$collectionId` | string | ID of the collection this document belongs to |
| `$databaseId` | string | ID of the database this collection belongs to |

### 🔑 ID Handling Pattern in Flutter Models

**IMPORTANT**: When parsing Appwrite documents in `fromJson()`, always check `$id` first:

```dart
// ✅ Correct pattern - check $id first, then fallback to id
factory Model.fromJson(Map<String, dynamic> json) => Model(
  id: json['\$id']?.toString() ?? json['id']?.toString(),
  createdAt: json['\$createdAt'] != null || json['createdAt'] != null
      ? DateTime.tryParse(json['\$createdAt']?.toString() ?? json['createdAt']?.toString() ?? '')
      : null,
  // ... other fields
);

// ❌ Wrong - will miss Appwrite's auto-generated ID
factory Model.fromJson(Map<String, dynamic> json) => Model(
  id: json['id']?.toString(),  // Won't find $id from Appwrite!
);
```

**Note**: The `$` prefix is a special character, so use escaped string `'\$id'` in Dart.

---

### 📸 Storage URL Pattern

When uploading files to Appwrite Storage, store the **full URL** in the database (not just the file ID). This simplifies image loading in the app.

**Upload Flow:**
```dart
// 1. Upload file to Storage bucket
final file = await storage.createFile(
  bucketId: 'profile_photos',  // or 'documents', 'vehicle_photos', etc.
  fileId: ID.unique(),
  file: InputFile.fromPath(path: localFilePath),
);

// 2. Generate the public view URL
final fileUrl = 'https://fra.cloud.appwrite.io/v1/storage/buckets/${bucketId}/files/${file.$id}/view?project=68ed397e000f277c6936';

// 3. Save URL to collection document
await databases.updateDocument(
  databaseId: 'godropme_db',
  collectionId: 'drivers',
  documentId: driverId,
  data: {
    'profilePhotoUrl': fileUrl,
  },
);
```

**Storage Buckets:**
| Bucket ID | Purpose | File Types |
|-----------|---------|------------|
| `profile_photos` | Parent & driver profile pictures | jpg, png |
| `child_photos` | Children's photos | jpg, png |
| `documents` | CNIC, license, registration | jpg, png, pdf |
| `vehicle_photos` | Vehicle images | jpg, png |
| `chat_images` | Chat message attachments | jpg, png |
| `report_attachments` | Report evidence files | jpg, png, pdf |

**URL Format:**
```
https://fra.cloud.appwrite.io/v1/storage/buckets/{bucketId}/files/{fileId}/view?project=68ed397e000f277c6936
```

---

### 🔗 Relationship Attributes (Created in Appwrite)

All collections are linked with proper relationship columns for data integrity and easy querying.

| From Collection | Relationship Key | Type | To Collection | Two-Way Key | On Delete |
|-----------------|------------------|------|---------------|-------------|-----------|
| `parents` | `user` | One-to-One | `users` | `parentProfile` | cascade |
| `drivers` | `user` | One-to-One | `users` | `driverProfile` | cascade |
| `children` | `parent` | Many-to-One | `parents` | `children` | cascade |
| `children` | `assignedDriver` | Many-to-One | `drivers` | `assignedChildren` | setNull |
| `vehicles` | `driver` | Many-to-One | `drivers` | `vehicle` | cascade |
| `driver_services` | `driver` | One-to-One | `drivers` | `service` | cascade |
| `service_requests` | `parentRef` | Many-to-One | `parents` | `serviceRequests` | cascade |
| `service_requests` | `driverRef` | Many-to-One | `drivers` | `receivedRequests` | cascade |
| `service_requests` | `childRef` | Many-to-One | `children` | `serviceRequests` | cascade |
| `active_services` | `parentRef` | Many-to-One | `parents` | `activeServices` | cascade |
| `active_services` | `driverRef` | Many-to-One | `drivers` | `activeServices` | cascade |
| `active_services` | `childRef` | Many-to-One | `children` | `activeService` | cascade |
| `trips` | `activeService` | Many-to-One | `active_services` | `trips` | cascade |
| `trips` | `driverRef` | Many-to-One | `drivers` | `trips` | cascade |
| `trips` | `childRef` | Many-to-One | `children` | `trips` | cascade |
| `trips` | `parentRef` | Many-to-One | `parents` | `trips` | cascade |
| `chat_rooms` | `parentRef` | Many-to-One | `parents` | `chatRooms` | cascade |
| `chat_rooms` | `driverRef` | Many-to-One | `drivers` | `chatRooms` | cascade |
| `messages` | `chatRoom` | Many-to-One | `chat_rooms` | `messages` | cascade |
| `notifications` | `userRef` | Many-to-One | `users` | `notifications` | cascade |
| `geofence_events` | `tripRef` | Many-to-One | `trips` | `geofenceEvents` | cascade |
| `geofence_events` | `driverRef` | Many-to-One | `drivers` | `geofenceEvents` | cascade |
| `trip_history` | `originalTrip` | One-to-One | `trips` | `historyRecord` | setNull |
| `ratings` | `driver` | Many-to-One | `drivers` | `ratings` | setNull |
| `ratings` | `parent` | Many-to-One | `parents` | `ratings` | setNull |
| `ratings` | `trip` | Many-to-One | `trips` | `rating` | setNull |

**Relationship Benefits:**
- **Cascade Delete**: When a parent is deleted, all their children, service requests, etc. are automatically deleted
- **SetNull**: When a driver is unassigned from a child, the `assignedDriverId` becomes null (child record preserved)
- **Two-Way Access**: Can query from either direction (e.g., get all children for a parent, or get parent for a child)

**Usage Example:**
```dart
// Get parent with all their children in one query
final parentDoc = await databases.getDocument(
  databaseId: 'godropme_db',
  collectionId: 'parents',
  documentId: parentId,
);
// parentDoc.data['children'] contains array of child documents

// Get driver with all their active services
final driverDoc = await databases.getDocument(
  databaseId: 'godropme_db',
  collectionId: 'drivers',
  documentId: driverId,
);
// driverDoc.data['activeServices'] contains array of service documents
```

---

### 📁 Collection 1: `users`
> Core user authentication and role management

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `email` | email | ✅ | - | User email (used for OTP auth) |
| `role` | enum | ✅ | - | Values: `parent`, `driver` |
| `isProfileComplete` | boolean | ✅ | false | Registration completed |
| `status` | enum | ✅ | `pending` | Values: `active`, `suspended`, `pending`, `rejected` |
| `statusReason` | string(500) | ❌ | null | Reason for suspension OR rejection (single field) |
| `fcmToken` | string(500) | ❌ | null | Push notification token |

**Removed Columns** (Dec 3, 2025):
- ~~`suspensionReason`~~ — Merged into `statusReason`
- ~~`rejectionReason`~~ — Merged into `statusReason`
- ~~`phone`~~ — Redundant (phone stored in parents/drivers tables)
- ~~`isApproved`~~ — Redundant (use `status` field instead)

**Note**: `statusReason` is used for both suspension and rejection reasons since a user can only have one status at a time.

**Indexes**:
- `email` (Unique)
- `role` (Key)
- `status` (Key)

---

### 📁 Collection 2: `parents`
> Parent profile and details

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `userId` | string(36) | ✅ | - | Reference to auth user $id |
| `fullName` | string(128) | ✅ | - | Parent's full name |
| `phone` | string(20) | ❌ | "" | Phone with country code (optional) |
| `email` | email | ✅ | - | Parent's email |
| `profilePhotoUrl` | url | ❌ | null | Profile photo URL from Storage |

**Indexes**:
- `userId` (Unique)
- `email` (Unique)

**Relationships**:
- One-to-Many → `children` (parent has many children)

---

### 📁 Collection 3: `schools` ⭐ NEW
> Central source of truth for school data (Dec 3, 2025)

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string(256) | ✅ | - | School name (unique) |
| `shortName` | string(50) | ❌ | null | Abbreviated name |
| `location` | point | ✅ | - | School coordinates `[lng, lat]` |
| `address` | string(500) | ❌ | null | Full street address |
| `city` | string(100) | ❌ | "Peshawar" | City name |
| `isActive` | boolean | ❌ | true | School is active |

**Indexes**:
- `name` (Unique) - Primary lookup
- `city` (Key) - Filter by city
- `isActive` (Key) - Filter active schools
- `location` (Key) - For geo queries

**Usage Pattern**:
```dart
// SchoolsLoader caches all schools for 1 hour
// O(1) lookups by ID or name
SchoolsLoader.getById(schoolId)     // → School
SchoolsLoader.getByIds(schoolIds)   // → List<School>
SchoolsLoader.getByName(name)       // → School?
```

**Relationships**:
- Referenced by `children.schoolId` (FK)
- Referenced by `driver_services.schoolIds[]` (FK array)

---

### 📁 Collection 4: `children`
> Children registered by parents

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `parentId` | relationship | ✅ | - | Many-to-One → `parents` |
| `name` | string(128) | ✅ | - | Child's name |
| `age` | integer | ✅ | - | Age (4-25) - **stored as integer** |
| `gender` | enum | ✅ | - | Values: `Male`, `Female` |
| `schoolId` | string(36) | ✅ | - | **FK to `schools` table** - School $id |
| `pickPoint` | string(1500) | ✅ | - | Pickup location address |
| `pickLocation` | point | ✅ | - | Pickup coordinates [lng, lat] |
| `dropPoint` | string(1500) | ✅ | - | Drop-off location address |
| `dropLocation` | point | ✅ | - | Drop-off coordinates [lng, lat] |
| `relationshipToChild` | string(50) | ✅ | - | Father, Mother, Guardian, etc. |
| `schoolOpenTime` | string(10) | ❌ | null | School opening time (e.g., "7:30 AM") |
| `schoolOffTime` | string(10) | ❌ | null | School closing time (e.g., "1:30 PM") |
| `photoUrl` | url | ❌ | null | Child photo URL from Storage |
| `specialNotes` | string(1000) | ❌ | null | Special instructions |
| `isActive` | boolean | ✅ | true | Currently needs service |
| `assignedDriverId` | string(36) | ❌ | null | Reference to drivers.$id |

**Removed Fields** (Dec 3, 2025 cleanup):
- ~~`schoolName`~~ — Now looked up via `SchoolsLoader.getById(schoolId)`
- ~~`schoolLocation`~~ — Now looked up via `SchoolsLoader.getById(schoolId).location`

**Field Mapping from Flutter Model:**
```dart
// ChildModel → Appwrite children collection
{
  'name': 'Ali',
  'age': 8,                              // integer (was string, now parsed)
  'gender': 'Male',
  'schoolId': 'abc123xyz...',            // FK to schools table
  'pickPoint': 'House 123, Street 5...',
  'pickLocation': [71.588, 34.021],      // point [lng, lat]
  'dropPoint': 'City School Gate...',
  'dropLocation': [71.518, 34.035],      // point [lng, lat]
  'relationshipToChild': 'Father',
  'schoolOpenTime': '7:30 AM',           // renamed from pickupTime
  'schoolOffTime': '1:30 PM',            // school closing time
}
// Display: Use SchoolsLoader.getById(schoolId).name
```

**Indexes**:
- `parentId` (Key)
- `schoolId` (Key) - For filtering by school
- `assignedDriverId` (Key)
- `isActive` (Key)
- `pickLocation` (Key) - For geo queries
- `dropLocation` (Key) - For geo queries

---

### 📁 Collection 5: `drivers`
> Driver profile and verification details

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `userId` | string(36) | ✅ | - | Reference to auth user $id |
| `fullName` | string(128) | ✅ | - | Driver's full name |
| `firstName` | string(50) | ✅ | - | First name |
| `surname` | string(50) | ❌ | null | Surname/middle name |
| `lastName` | string(50) | ✅ | - | Last name |
| `phone` | string(20) | ✅ | - | Phone with country code |
| `email` | email | ✅ | - | Driver's email |
| `profilePhotoUrl` | url | ✅ | - | Profile photo URL from Storage |
| `cnicNumber` | string(13) | ✅ | - | 13-digit CNIC (no dashes) |
| `cnicExpiry` | datetime | ❌ | null | CNIC expiry date |
| `cnicFrontUrl` | url | ✅ | - | CNIC front photo URL from Storage |
| `cnicBackUrl` | url | ✅ | - | CNIC back photo URL from Storage |
| `licenseNumber` | string(50) | ✅ | - | Driving license number |
| `licenseExpiry` | datetime | ✅ | - | License expiry date |
| `licensePhotoUrl` | url | ✅ | - | License photo URL from Storage |
| `selfieWithLicenseUrl` | url | ✅ | - | Selfie with license URL from Storage |
| `rating` | float | ❌ | 0.0 | Average rating (1-5) |
| `totalTrips` | integer | ❌ | 0 | Total completed trips |
| `totalRatings` | integer | ❌ | 0 | Number of ratings received |
| `isOnline` | boolean | ✅ | false | Currently accepting rides |
| `currentLocation` | point | ❌ | null | Real-time location [lng, lat] |
| `lastLocationUpdate` | datetime | ❌ | null | Timestamp of last location update |

**Removed Columns** (Dec 3, 2025):
- ~~`verificationStatus`~~ — Status is now managed in `users.status` table only

**Note**: Driver verification/approval status is now unified in the `users` table (`status` field). This eliminates redundancy and ensures a single source of truth.

**Indexes**:
- `userId` (Unique)
- `email` (Unique)
- `cnicNumber` (Unique)
- `licenseNumber` (Unique)
- `isOnline` (Key)
- `currentLocation` (Key) - For geo queries & geofencing

---

### 📁 Collection 6: `vehicles`
> Driver's vehicle information

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `driverId` | relationship | ✅ | - | One-to-One → `drivers` |
| `vehicleType` | enum | ✅ | - | Values: `car`, `rikshaw` |
| `brand` | string(50) | ✅ | - | Vehicle brand |
| `model` | string(50) | ✅ | - | Vehicle model |
| `color` | string(30) | ✅ | - | Vehicle color |
| `productionYear` | string(4) | ✅ | - | Year of manufacture |
| `numberPlate` | string(20) | ✅ | - | License plate number |
| `seatCapacity` | integer | ✅ | - | Number of seats available |
| `vehiclePhotoUrl` | url | ✅ | - | Vehicle photo URL from Storage |
| `registrationFrontUrl` | url | ✅ | - | Registration front URL from Storage |
| `registrationBackUrl` | url | ✅ | - | Registration back URL from Storage |
| `isActive` | boolean | ✅ | true | Currently in use |

**Indexes**:
- `driverId` (Unique)
- `numberPlate` (Unique)
- `vehicleType` (Key)

---

### 📁 Collection 7: `driver_services`
> Driver's service configuration

> **Note**: Service windows are **system-managed** (Morning: 5-9 AM → home_to_school, Afternoon: 11 AM-3 PM → school_to_home). Drivers don't select windows — trips are auto-generated for both.

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `driverId` | relationship | ✅ | - | One-to-One → `drivers` |
| `schoolIds` | string[](36) | ✅ | - | **FK array to `schools` table** - School $ids driver serves |
| `serviceCategory` | enum | ✅ | - | Gender category: 'Male', 'Female', or 'Both' |
| `serviceAreaCenter` | point | ✅ | - | Center of service area `[lng, lat]` |
| `serviceAreaRadiusKm` | float | ✅ | - | Radius of service area (0.2 - 2 km, colony-level) |
| `serviceAreaPolygon` | polygon | ✅ | - | Service area boundary `[[[lng, lat], ...]]` (3D array, closed ring) |
| `serviceAreaAddress` | string(1500) | ❌ | null | Human-readable address of center |
| `monthlyPricePkr` | integer | ✅ | - | Monthly service price in PKR |
| `extraNotes` | string(1000) | ❌ | null | Additional notes |

**Appwrite Geo Format Notes**:
- **Point**: `[longitude, latitude]` (2D array of 2 numbers)
- **Polygon**: `[[[lng, lat], [lng, lat], ..., [lng, lat]]]` (3D array)
  - Outer array holds one or more linear rings
  - First ring is exterior boundary, additional rings are holes
  - Each ring must be **closed** (first point = last point)

**Removed Fields** (from previous version):
- ~~`schoolNames`~~ — **DELETED Dec 3, 2025** - Now looked up via `SchoolsLoader.getByIds(schoolIds)`
- ~~`schoolPoints`~~ — **DELETED Dec 3, 2025** - Now looked up via `SchoolsLoader.getByIds(schoolIds)[].location`
- ~~`serviceWindow`~~ — System generates trips for both morning & afternoon automatically
- ~~`pickupRangeKm` (enum)~~ — Replaced by `serviceAreaRadiusKm` (float) + `serviceAreaPolygon`
- ~~`isActive`~~ — Removed from UI; drivers are active if they have a valid service doc
- ~~`routeStartAddress`/`routeStartLocation`~~ — Replaced by `serviceAreaCenter`/`serviceAreaAddress`
- ~~`operatingDays`~~ — Removed; all drivers operate Mon-Fri by default, no user selection needed

**Restored Assets**:
- `assets/json/driver_details.json` — Contains `serviceCategories` array for dropdown options

**Indexes**:
- `driverId` (Unique)
- `serviceCategory` (Key) - For filtering by gender category
- `serviceAreaCenter` (Key) - For geo queries
- `serviceAreaPolygon` (Key) - For spatial driver-parent matching (point-in-polygon)

---

### 📁 Collection 8: `service_requests`
> Parent requests for driver service

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `parentId` | relationship | ✅ | - | Many-to-One → `parents` |
| `driverId` | relationship | ✅ | - | Many-to-One → `drivers` |
| `childId` | relationship | ✅ | - | Many-to-One → `children` |
| `status` | enum | ✅ | `pending` | Values: `pending`, `accepted`, `rejected`, `cancelled` |
| `requestType` | enum | ✅ | - | Values: `pickup`, `dropoff`, `both` |
| `message` | string(500) | ❌ | null | Message to driver |
| `proposedPrice` | float | ❌ | null | Proposed monthly fee (PKR) |
| `responseMessage` | string(500) | ❌ | null | Driver's response |
| `respondedAt` | datetime | ❌ | null | Response timestamp |

**Indexes**:
- `parentId` (Key)
- `driverId` (Key)
- `childId` (Key)
- `status` (Key)

---

### 📁 Collection 9: `active_services`
> Ongoing parent-driver service contracts

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `parentId` | relationship | ✅ | - | Many-to-One → `parents` |
| `driverId` | relationship | ✅ | - | Many-to-One → `drivers` |
| `childId` | relationship | ✅ | - | Many-to-One → `children` |
| `serviceType` | enum | ✅ | - | Values: `pickup`, `dropoff`, `both` |
| `monthlyFee` | float | ✅ | - | Agreed monthly fee (PKR) |
| `startDate` | datetime | ✅ | - | Service start date |
| `endDate` | datetime | ❌ | null | Service end date |
| `status` | enum | ✅ | `active` | Values: `active`, `paused`, `ended` |

**Indexes**:
- `parentId` (Key)
- `driverId` (Key)
- `childId` (Key)
- `status` (Key)

---

### 📁 Collection 10: `trips`
> Daily trip records for tracking

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `activeServiceId` | relationship | ✅ | - | Many-to-One → `active_services` |
| `driverId` | string(36) | ✅ | - | Driver document ID |
| `childId` | string(36) | ✅ | - | Child document ID |
| `parentId` | string(36) | ✅ | - | Parent document ID |
| `tripType` | enum | ✅ | - | Values: `morning`, `afternoon` |
| `tripDirection` | enum | ✅ | - | Values: `home_to_school`, `school_to_home` |
| `status` | enum | ✅ | `scheduled` | Values: `scheduled`, `driver_enroute`, `arrived`, `picked`, `in_transit`, `dropped`, `cancelled`, `absent` |
| `scheduledDate` | datetime | ✅ | - | Scheduled date |
| `windowStartTime` | string(10) | ✅ | - | Window start time (HH:MM) |
| `windowEndTime` | string(10) | ✅ | - | Window end time (HH:MM) |
| `driverEnrouteAt` | datetime | ❌ | null | Driver started moving |
| `arrivedAt` | datetime | ❌ | null | Driver arrived at pickup |
| `pickedAt` | datetime | ❌ | null | Child picked up |
| `inTransitAt` | datetime | ❌ | null | Started traveling to destination |
| `droppedAt` | datetime | ❌ | null | Child dropped off |
| `pickupLocation` | point | ✅ | - | Pickup [lng, lat] |
| `dropLocation` | point | ✅ | - | Drop-off [lng, lat] |
| `currentDriverLocation` | point | ❌ | null | Real-time driver location |
| `liveTrackingEnabled` | boolean | ✅ | false | Parent can see driver on map |
| `parentConfirmed` | boolean | ❌ | false | Parent confirmed drop-off |
| `approachingNotified` | boolean | ✅ | false | Approaching notification sent |
| `arrivedNotified` | boolean | ✅ | false | Arrived notification sent |
| `pickedNotified` | boolean | ✅ | false | Picked notification sent |
| `droppedNotified` | boolean | ✅ | false | Dropped notification sent |
| `notes` | string(500) | ❌ | null | Trip notes |
| `absentReason` | string(200) | ❌ | null | Reason if child absent |

**Indexes**:
- `driverId` (Key)
- `childId` (Key)
- `parentId` (Key)
- `activeServiceId` (Key)
- `status` (Key)
- `scheduledDate` (Key)
- `tripType` (Key)
- `tripDirection` (Key)
- `pickupLocation` (Key) - For geofencing
- `dropLocation` (Key) - For geofencing
- `currentDriverLocation` (Key) - For distance queries

---

### 📁 Collection 11: `chat_rooms`
> Chat rooms between parents and drivers (Realtime enabled)

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `parentId` | relationship | ✅ | - | Many-to-One → `parents` |
| `driverId` | relationship | ✅ | - | Many-to-One → `drivers` |
| `lastMessage` | string(500) | ❌ | null | Last message preview |
| `lastMessageAt` | datetime | ❌ | null | Last message timestamp |
| `parentUnreadCount` | integer | ✅ | 0 | Unread count for parent |
| `driverUnreadCount` | integer | ✅ | 0 | Unread count for driver |

**Indexes**:
- `parentId` (Key)
- `driverId` (Key)
- Composite: `parentId` + `driverId` (Unique)

**Realtime Subscription**:
```dart
// Subscribe to chat room updates
client.subscribe('databases.godropme_db.collections.chat_rooms.documents');
```

---

### 📁 Collection 12: `messages`
> Chat messages (Realtime enabled)

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `chatRoomId` | relationship | ✅ | - | Many-to-One → `chat_rooms` |
| `senderId` | string(36) | ✅ | - | Sender user/parent/driver ID |
| `senderRole` | enum | ✅ | - | Values: `parent`, `driver` |
| `messageType` | enum | ✅ | `text` | Values: `text`, `image`, `location` |
| `text` | string(2000) | ❌ | null | Message content |
| `imageUrl` | url | ❌ | null | Image URL from Storage |
| `location` | point | ❌ | null | Shared location [lng, lat] |
| `isRead` | boolean | ✅ | false | Message read status |

**Indexes**:
- `chatRoomId` (Key)
- `senderId` (Key)

**Realtime Subscription**:
```dart
// Subscribe to messages in a chat room
client.subscribe('databases.godropme_db.collections.messages.documents.$chatRoomId');
```

---

### 📁 Collection 13: `notifications`
> Push notification records

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `userId` | string(36) | ✅ | - | Target user auth ID |
| `targetRole` | enum | ✅ | - | Values: `parent`, `driver` |
| `title` | string(100) | ✅ | - | Notification title |
| `body` | string(500) | ✅ | - | Notification body |
| `type` | enum | ✅ | - | Values: `trip_started`, `driver_arrived`, `child_picked`, `child_dropped`, `request_received`, `request_accepted`, `request_rejected`, `new_message`, `system` |
| `data` | string(2000) | ❌ | null | JSON payload for navigation |
| `isRead` | boolean | ✅ | false | Read status |

**Indexes**:
- `userId` (Key)
- `targetRole` (Key)
- `type` (Key)
- `isRead` (Key)

---

### 📁 Collection 14: `reports`
> User reports and complaints

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `reporterId` | string(36) | ✅ | - | Reporter's document ID |
| `reporterRole` | enum | ✅ | - | Values: `parent`, `driver` |
| `reportedUserId` | string(36) | ❌ | null | Reported user's ID |
| `tripId` | string(36) | ❌ | null | Related trip ID |
| `reportType` | enum | ✅ | - | Values: `safety`, `behavior`, `service`, `app_issue`, `other` |
| `title` | string(200) | ✅ | - | Report title |
| `description` | string(2000) | ✅ | - | Detailed description |
| `attachmentUrls` | string(2000) | ❌ | null | JSON array of attachment URLs |
| `status` | enum | ✅ | `pending` | Values: `pending`, `investigating`, `resolved`, `dismissed` |
| `adminNotes` | string(1000) | ❌ | null | Admin response |
| `resolvedAt` | datetime | ❌ | null | Resolution timestamp |

**Indexes**:
- `reporterId` (Key)
- `reportedUserId` (Key)
- `status` (Key)
- `reportType` (Key)

---

### 📁 Collection 15: `geofence_events`
> Geofencing event logs for arrival notifications

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `tripId` | relationship | ✅ | - | Many-to-One → `trips` |
| `driverId` | string(36) | ✅ | - | Driver document ID |
| `eventType` | enum | ✅ | - | Values: `approaching_pickup`, `arrived_pickup`, `departed_pickup`, `approaching_dropoff`, `arrived_dropoff` |
| `driverLocation` | point | ✅ | - | Driver location at event [lng, lat] |
| `targetLocation` | point | ✅ | - | Target (pickup/drop) location |
| `distanceMeters` | float | ✅ | - | Distance from target in meters |
| `notificationSent` | boolean | ✅ | false | Was notification sent |

**Indexes**:
- `tripId` (Key)
- `driverId` (Key)
- `eventType` (Key)

---

### 📁 Collection 16: `daily_analytics`
> Daily trip analytics and statistics for monitoring and reports

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `date` | datetime | ✅ | - | Date of analytics (start of day) |
| `totalActiveServices` | integer | ✅ | 0 | Total active services on this date |
| `totalMorningTrips` | integer | ✅ | 0 | Morning trips scheduled |
| `totalAfternoonTrips` | integer | ✅ | 0 | Afternoon trips scheduled |
| `completedMorningTrips` | integer | ✅ | 0 | Morning trips successfully completed |
| `completedAfternoonTrips` | integer | ✅ | 0 | Afternoon trips successfully completed |
| `cancelledTrips` | integer | ✅ | 0 | Trips cancelled |
| `absentChildren` | integer | ✅ | 0 | Children marked absent |
| `noShowTrips` | integer | ✅ | 0 | Trips where driver arrived but child not ready |
| `avgPickupDelayMins` | float | ❌ | null | Avg delay between scheduled & actual pickup |
| `avgTripDurationMins` | float | ❌ | null | Avg duration from pickup to drop |
| `activeDrivers` | integer | ✅ | 0 | Drivers who had at least one trip |
| `newServiceRequests` | integer | ✅ | 0 | New service requests created |
| `acceptedRequests` | integer | ✅ | 0 | Service requests accepted by drivers |
| `rejectedRequests` | integer | ✅ | 0 | Service requests rejected |
| `totalNotificationsSent` | integer | ✅ | 0 | Notifications sent |
| `geofenceEventsCount` | integer | ✅ | 0 | Geofence events logged |
| `avgDriverRating` | float | ❌ | null | Average driver rating for trips on this day |
| `issuesReported` | integer | ✅ | 0 | Reports/complaints filed |

**Indexes**:
- `date` (Unique) — One document per day
- `$createdAt` (Key) — For ordering

> **Note**: Analytics are generated daily at **11:59 PM PKT** by the `generate-daily-analytics` function, summarizing the day's activity.

---

### 📁 Collection 17: `trip_history`
> Individual trip history records for detailed reporting

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `tripId` | string(36) | ✅ | - | Original trip document ID |
| `driverId` | string(36) | ✅ | - | Driver document ID |
| `childId` | string(36) | ✅ | - | Child document ID |
| `parentId` | string(36) | ✅ | - | Parent document ID |
| `activeServiceId` | string(36) | ✅ | - | Active service ID |
| `tripType` | enum | ✅ | - | Values: `morning`, `afternoon` |
| `tripDirection` | enum | ✅ | - | Values: `home_to_school`, `school_to_home` |
| `scheduledDate` | datetime | ✅ | - | Original scheduled date |
| `status` | enum | ✅ | - | Final status: `completed`, `cancelled`, `absent`, `no_show` |
| `driverEnrouteAt` | datetime | ❌ | null | When driver started trip |
| `arrivedAt` | datetime | ❌ | null | When driver arrived at pickup |
| `pickedAt` | datetime | ❌ | null | When child was picked up |
| `droppedAt` | datetime | ❌ | null | When child was dropped off |
| `pickupDelayMins` | integer | ❌ | null | Delay from scheduled time |
| `tripDurationMins` | integer | ❌ | null | Total trip time (arrived → dropped) |
| `driverRating` | float | ❌ | null | Rating given for this trip |
| `parentFeedback` | string(500) | ❌ | null | Parent feedback |
| `incidentNotes` | string(500) | ❌ | null | Any incident notes |

**Indexes**:
- `driverId` (Key)
- `parentId` (Key)
- `childId` (Key)
- `scheduledDate` (Key)
- `status` (Key)

> **Note**: Trip history is created when a trip reaches a terminal state (`completed`, `cancelled`, `absent`, `no_show`). This allows the `trips` collection to be cleaned up while preserving historical data.

---

### 📁 Collection 18: `ratings`
> Driver ratings from parents after trips

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `driverId` | string(36) | ✅ | - | Driver being rated |
| `parentId` | string(36) | ✅ | - | Parent who gave rating |
| `tripId` | string(36) | ❌ | null | Optional trip reference |
| `rating` | integer (1-5) | ✅ | - | Star rating (1-5) |
| `review` | string(1000) | ❌ | null | Optional text review |
| `createdAt` | datetime | ✅ | - | When rating was submitted |

**Relationships**:
- `driver` → `drivers` (Many-to-One) — Two-way key: `ratings`
- `parent` → `parents` (Many-to-One) — Two-way key: `ratings`
- `trip` → `trips` (Many-to-One) — Two-way key: `rating`

**Indexes**:
- `driver_idx` (Key) — For querying ratings by driver
- `parent_idx` (Key) — For querying ratings by parent
- `trip_idx` (Key) — For querying rating by trip
- `created_idx` (Key, DESC) — For ordering recent ratings first

> **Note**: This collection triggers the `calculate-driver-rating` function on document create to update the driver's average rating in the `drivers` collection.

---

## 📦 Storage Buckets

| Bucket ID | Purpose | Max Size | Allowed Types | Permissions |
|-----------|---------|----------|---------------|-------------|
| `profile_photos` | User profile photos | 5MB | jpg, jpeg, png, webp | Authenticated users |
| `documents` | CNIC, License, Registration | 10MB | jpg, jpeg, png, pdf | Owner only |
| `vehicle_photos` | Vehicle photos | 10MB | jpg, jpeg, png, webp | Owner only |
| `child_photos` | Children's photos | 5MB | jpg, jpeg, png, webp | Parent only |
| `chat_attachments` | Chat image attachments | 5MB | jpg, jpeg, png, webp | Chat participants |
| `report_attachments` | Report evidence | 10MB | jpg, jpeg, png, pdf | Reporter only |

---

## 🕐 Service Windows & Trip Flow

### Service Window Concept

GoDropMe operates on a **two-window daily service model** based on **Pakistan school timings**:

| Window | Time Range | Direction | Pickup From | Drop At |
|--------|------------|-----------|-------------|---------|
| **Morning** | 5:00 AM - 9:00 AM | Home → School | Child's Home | School |
| **Afternoon** | 11:00 AM - 3:00 PM | School → Home | School | Child's Home |

> **Note**: Service windows are **system-managed** — drivers don't select them. Trip generation is **split into two separate scheduled functions** for precise timing.

### Daily Trip Generation Logic (Split Functions)

**🌅 Morning Trips** — Generated at **5:00 AM PKT** via `generate-morning-trips`:
```
1. Get all active_services where status = 'active'
2. For each service where driver offers morning:
   a. Get child's pickupLocation (home) and dropLocation (school)
   b. Create MORNING trip (home_to_school):
      - pickupLocation = child's home
      - dropLocation = school
      - tripType = 'morning'
      - tripDirection = 'home_to_school'
      - windowStartTime = 05:00
      - windowEndTime = 09:00
```

**🌤️ Afternoon Trips** — Generated at **11:00 AM PKT** via `generate-afternoon-trips`:
```
1. Get all active_services where status = 'active'
2. For each service where driver offers afternoon:
   a. Get child's pickupLocation (home) and dropLocation (school)
   b. Create AFTERNOON trip (school_to_home):
      - pickupLocation = school
      - dropLocation = child's home
      - tripType = 'afternoon'
      - tripDirection = 'school_to_home'
      - windowStartTime = 11:00
      - windowEndTime = 15:00
```

> **Why Split?** Generating trips closer to their actual window ensures:
> - More accurate driver availability tracking
> - Allows for same-day changes (e.g., child marked absent before afternoon trips are created)
> - Reduces system load by spreading operations

### Trip Status Flow

```
MORNING Trip (Home → School):
┌─────────────┐    ┌─────────────────┐    ┌─────────────┐    ┌─────────┐
│  scheduled  │ →  │  driver_enroute │ →  │   arrived   │ →  │ picked  │
└─────────────┘    └─────────────────┘    └─────────────┘    └─────────┘
                         ↓                      ↓                 ↓
                   Driver starts          At child's home    Child in vehicle
                   ↓                      ↓                       ↓
                   📍 Live tracking      🔔 "Driver Arrived"     ↓
                      starts                notification        ↓
                                                                ↓
                                         ┌────────────┐    ┌─────────┐
                                         │ in_transit │ →  │ dropped │
                                         └────────────┘    └─────────┘
                                              ↓                 ↓
                                         Traveling to       At school
                                           school         🔔 "Child Dropped"
                                         📍 Parent can         notification
                                           track live

AFTERNOON Trip (School → Home):
Same flow but:
- pickupLocation = School
- dropLocation = Child's Home
- "arrived" = Driver at school
- "dropped" = Child safely home
```

### Parent Real-Time Tracking

When a trip status becomes `driver_enroute` or `in_transit`:

1. `liveTrackingEnabled` is set to `true` on the trip
2. Parent app subscribes to Realtime updates:
   ```dart
   realtime.subscribe([
     'databases.godropme_db.collections.trips.documents.$tripId'
   ]);
   ```
3. Driver's app updates `currentDriverLocation` every 5-10 seconds
4. Parent sees driver's position on map in real-time
5. When status becomes `dropped`, tracking stops

### Notification Timeline

```
Morning Trip (5-9 AM Window):
┌───────────────────────────────────────────────────────────────────────┐
│ 6:30 AM │ Driver starts route     │ 🔔 "Driver has started the route" │
│ 6:45 AM │ 500m from home          │ 🔔 "Driver is approaching"        │
│ 6:50 AM │ Arrived at home (<100m) │ 🔔 "Driver has arrived!"          │
│ 6:52 AM │ Child picked up         │ 🔔 "Your child has been picked up"│
│ 7:15 AM │ Arrived at school       │ 🔔 "Your child has been dropped"  │
└───────────────────────────────────────────────────────────────────────┘

Afternoon Trip (12-3 PM Window):
┌───────────────────────────────────────────────────────────────────────┐
│ 1:30 PM │ Driver at school gate   │ 🔔 "Driver waiting at school"     │
│ 1:35 PM │ Child picked up         │ 🔔 "Your child has been picked up"│
│ 1:50 PM │ 500m from home          │ 🔔 "Driver is approaching home"   │
│ 1:55 PM │ Arrived at home (<100m) │ 🔔 "Driver has arrived home!"     │
│ 1:57 PM │ Child dropped           │ 🔔 "Your child is safely home"    │
└───────────────────────────────────────────────────────────────────────┘
```

### Geofence Radius Configuration

| Event | Radius | Notification |
|-------|--------|--------------|
| Approaching | 500m | "Driver is X minutes away" |
| Arrived | 100m | "Driver has arrived" |
| Picked | - | "Child picked up" (manual trigger) |
| Dropped | 100m from dropLocation | "Child dropped off safely" |

### 📱 Driver App: Trip Display Logic

The driver app displays trips based on **current time window**:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        DRIVER HOME SCREEN                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Time: 5:00 AM - 10:59 AM                                               │
│  ────────────────────────                                               │
│  📱 Shows: MORNING trips (tripType = 'morning')                         │
│  📍 Direction: Home → School                                            │
│  🏠 Pickup: Child's home addresses                                      │
│  🏫 Drop: School locations                                              │
│                                                                          │
│  Time: 11:00 AM - 4:00 PM                                               │
│  ────────────────────────                                               │
│  📱 Shows: AFTERNOON trips (tripType = 'afternoon')                     │
│  📍 Direction: School → Home                                            │
│  🏫 Pickup: School gate/designated area                                 │
│  🏠 Drop: Child's home addresses                                        │
│                                                                          │
│  Time: 4:01 PM - 4:59 AM                                                │
│  ────────────────────────                                               │
│  📱 Shows: No active trips (off-hours)                                  │
│  📍 Display: "No trips scheduled" or next day preview                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

**Driver App Query Logic:**
```dart
// In DriverHomeController.fetchTodaysTrips()
final now = DateTime.now();
final tripType = (now.hour >= 5 && now.hour < 11) ? 'morning' : 'afternoon';

final trips = await databases.listDocuments('godropme_db', 'trips', [
  Query.equal('driverId', currentDriverId),
  Query.equal('tripType', tripType),
  Query.greaterThanEqual('scheduledDate', todayStart.toIso8601String()),
  Query.lessThan('scheduledDate', tomorrowStart.toIso8601String()),
  Query.notEqual('status', 'cancelled'),
  Query.notEqual('status', 'dropped'),
]);
```

**Trip Card Display:**
| Field | Morning Display | Afternoon Display |
|-------|-----------------|-------------------|
| Pickup Icon | 🏠 (Home) | 🏫 (School) |
| Pickup Label | "Pickup from Home" | "Pickup from School" |
| Drop Icon | 🏫 (School) | 🏠 (Home) |
| Drop Label | "Drop at School" | "Drop at Home" |
| Window | "5:00 AM - 9:00 AM" | "11:00 AM - 3:00 PM" |
| Direction Badge | "Home → School" | "School → Home" |

---

## 🌍 Geo Queries & Geofencing

### Available Geo Query Methods:
```dart
// Find drivers within X meters of a point
Query.distanceLessThan('currentLocation', [longitude, latitude], 5000) // 5km radius

// Find if driver is within pickup zone (polygon)
Query.intersects('currentLocation', pickupZonePolygon)

// Find nearby schools
Query.distanceLessThan('location', [lng, lat], 3000)
```

### Geofencing Logic (Appwrite Function):
```
When driver location updates:
  1. Check distance to next pickup/drop point
  2. If distance < 500m → "Driver Approaching" notification
  3. If distance < 100m → "Driver Arrived" notification
  4. Log event in geofence_events collection
```

---

## ⚡ Appwrite Functions

### Function 1a: `generate-morning-trips`
> **Trigger**: CRON (Daily at **5:00 AM PKT** — `0 5 * * *` in Asia/Karachi)  
> **Runtime**: Node.js 18+  
> **Purpose**: Create MORNING trip records from active services

```javascript
// Input: None (CRON triggered)
// Output: Created morning trip count

export default async ({ req, res, log }) => {
  const today = new Date();
  const dayOfWeek = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][today.getDay()];
  
  // Skip weekends (no school)
  if (dayOfWeek === 'sunday') {
    return res.json({ success: true, message: 'Sunday - no trips', tripsCreated: 0 });
  }
  
  // Get all active services
  const activeServices = await databases.listDocuments(
    'godropme_db', 
    'active_services',
    [Query.equal('status', 'active')]
  );
  
  let count = 0;
  
  for (const service of activeServices.documents) {
    const driverConfig = await databases.getDocument('godropme_db', 'driver_services', service.driverId);
    const child = await databases.getDocument('godropme_db', 'children', service.childId);
    
    // Check if driver operates today
    const operatingDays = JSON.parse(driverConfig.operatingDays);
    if (!operatingDays.includes(dayOfWeek)) continue;
    
    // Only create if driver offers morning service
    if (driverConfig.serviceWindow === 'morning' || driverConfig.serviceWindow === 'both') {
      await databases.createDocument('godropme_db', 'trips', ID.unique(), {
        activeServiceId: service.$id,
        driverId: service.driverId,
        childId: service.childId,
        parentId: service.parentId,
        tripType: 'morning',
        tripDirection: 'home_to_school',
        status: 'scheduled',
        scheduledDate: today.toISOString(),
        windowStartTime: driverConfig.morningStartTime || '05:00',
        windowEndTime: driverConfig.morningEndTime || '09:00',
        pickupLocation: child.pickupLocation,  // Home
        dropLocation: child.dropLocation,      // School
        liveTrackingEnabled: false,
        approachingNotified: false,
        arrivedNotified: false,
        pickedNotified: false,
        droppedNotified: false
      });
      count++;
    }
  }
  
  log(`Generated ${count} morning trips for ${today.toDateString()}`);
  return res.json({ success: true, tripType: 'morning', tripsCreated: count });
};
```

### Function 1b: `generate-afternoon-trips`
> **Trigger**: CRON (Daily at **11:00 AM PKT** — `0 11 * * *` in Asia/Karachi)  
> **Runtime**: Node.js 18+  
> **Purpose**: Create AFTERNOON trip records from active services

```javascript
// Input: None (CRON triggered)
// Output: Created afternoon trip count

export default async ({ req, res, log }) => {
  const today = new Date();
  const dayOfWeek = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][today.getDay()];
  
  // Skip weekends (no school)
  if (dayOfWeek === 'sunday') {
    return res.json({ success: true, message: 'Sunday - no trips', tripsCreated: 0 });
  }
  
  // Get all active services
  const activeServices = await databases.listDocuments(
    'godropme_db', 
    'active_services',
    [Query.equal('status', 'active')]
  );
  
  let count = 0;
  
  for (const service of activeServices.documents) {
    const driverConfig = await databases.getDocument('godropme_db', 'driver_services', service.driverId);
    const child = await databases.getDocument('godropme_db', 'children', service.childId);
    
    // Check if driver operates today
    const operatingDays = JSON.parse(driverConfig.operatingDays);
    if (!operatingDays.includes(dayOfWeek)) continue;
    
    // Check if child was marked absent for afternoon
    // (Parent can mark absent before 11 AM, so afternoon trip won't be created)
    if (service.absentToday === true && service.absentWindow === 'afternoon') {
      log(`Skipping afternoon trip for child ${service.childId} - marked absent`);
      continue;
    }
    
    // Only create if driver offers afternoon service
    if (driverConfig.serviceWindow === 'afternoon' || driverConfig.serviceWindow === 'both') {
      await databases.createDocument('godropme_db', 'trips', ID.unique(), {
        activeServiceId: service.$id,
        driverId: service.driverId,
        childId: service.childId,
        parentId: service.parentId,
        tripType: 'afternoon',
        tripDirection: 'school_to_home',
        status: 'scheduled',
        scheduledDate: today.toISOString(),
        windowStartTime: driverConfig.afternoonStartTime || '11:00',
        windowEndTime: driverConfig.afternoonEndTime || '15:00',
        pickupLocation: child.dropLocation,   // School
        dropLocation: child.pickupLocation,   // Home
        liveTrackingEnabled: false,
        approachingNotified: false,
        arrivedNotified: false,
        pickedNotified: false,
        droppedNotified: false
      });
      count++;
    }
  }
  
  log(`Generated ${count} afternoon trips for ${today.toDateString()}`);
  return res.json({ success: true, tripType: 'afternoon', tripsCreated: count });
};
```

### Function 2: `process-geofence`
> **Trigger**: Event - `databases.godropme_db.collections.trips.documents.*.update`  
> **Runtime**: Node.js 18+  
> **Purpose**: Handle geofencing and send arrival notifications to parents

```javascript
// When driver location updates in a trip document
export default async ({ req, res, log }) => {
  const trip = req.body;
  
  // Only process if trip is active (driver_enroute or in_transit)
  if (!['driver_enroute', 'in_transit', 'picked'].includes(trip.status)) {
    return res.json({ skipped: true });
  }
  
  const driverLocation = trip.currentDriverLocation;
  if (!driverLocation) return res.json({ skipped: true });
  
  // Determine target based on status
  let targetLocation, notificationType;
  if (trip.status === 'driver_enroute') {
    targetLocation = trip.pickupLocation;  // Going to pickup
    notificationType = 'pickup';
  } else if (trip.status === 'picked' || trip.status === 'in_transit') {
    targetLocation = trip.dropLocation;    // Going to drop
    notificationType = 'dropoff';
  }
  
  const distance = calculateHaversineDistance(driverLocation, targetLocation);
  
  // 500m - Approaching notification
  if (distance < 500 && !trip.approachingNotified) {
    const directionText = notificationType === 'pickup' 
      ? 'is approaching for pickup' 
      : 'is approaching your home';
    
    await sendPushNotification(trip.parentId, {
      title: '🚗 Driver Approaching',
      body: `Driver ${directionText}. About 2-3 minutes away.`,
      type: 'driver_approaching',
      data: { tripId: trip.$id }
    });
    
    await databases.updateDocument('godropme_db', 'trips', trip.$id, {
      approachingNotified: true
    });
    
    // Log geofence event
    await databases.createDocument('godropme_db', 'geofence_events', ID.unique(), {
      tripId: trip.$id,
      driverId: trip.driverId,
      eventType: notificationType === 'pickup' ? 'approaching_pickup' : 'approaching_dropoff',
      driverLocation: driverLocation,
      targetLocation: targetLocation,
      distanceMeters: distance,
      notificationSent: true
    });
  }
  
  // 100m - Arrived notification
  if (distance < 100 && !trip.arrivedNotified) {
    const directionText = notificationType === 'pickup' 
      ? 'has arrived for pickup!' 
      : 'has arrived at your home!';
    
    await sendPushNotification(trip.parentId, {
      title: '📍 Driver Arrived',
      body: `Driver ${directionText}`,
      type: 'driver_arrived',
      data: { tripId: trip.$id }
    });
    
    await databases.updateDocument('godropme_db', 'trips', trip.$id, {
      arrivedNotified: true,
      arrivedAt: new Date().toISOString()
    });
  }
  
  return res.json({ processed: true, distance: distance });
};

function calculateHaversineDistance(point1, point2) {
  const R = 6371e3; // Earth radius in meters
  const lat1 = point1[1] * Math.PI / 180;
  const lat2 = point2[1] * Math.PI / 180;
  const deltaLat = (point2[1] - point1[1]) * Math.PI / 180;
  const deltaLon = (point2[0] - point1[0]) * Math.PI / 180;
  
  const a = Math.sin(deltaLat/2) ** 2 +
            Math.cos(lat1) * Math.cos(lat2) * Math.sin(deltaLon/2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  
  return R * c; // Distance in meters
}
```

### Function 3: `notify-trip-status`
> **Trigger**: Event - `databases.godropme_db.collections.trips.documents.*.update`  
> **Runtime**: Node.js 18+  
> **Purpose**: Send notifications when trip status changes (picked, dropped)

```javascript
export default async ({ req, res, log }) => {
  const trip = req.body;
  const previousStatus = req.headers['x-appwrite-trigger-status']; // If available
  
  // Child Picked Up
  if (trip.status === 'picked' && !trip.pickedNotified) {
    const child = await databases.getDocument('godropme_db', 'children', trip.childId);
    
    await sendPushNotification(trip.parentId, {
      title: '✅ Child Picked Up',
      body: `${child.name} has been picked up and is on the way to ${trip.tripDirection === 'home_to_school' ? 'school' : 'home'}.`,
      type: 'child_picked',
      data: { tripId: trip.$id, childId: trip.childId }
    });
    
    await databases.updateDocument('godropme_db', 'trips', trip.$id, {
      pickedNotified: true,
      pickedAt: new Date().toISOString(),
      liveTrackingEnabled: true  // Enable parent tracking
    });
  }
  
  // Child Dropped Off
  if (trip.status === 'dropped' && !trip.droppedNotified) {
    const child = await databases.getDocument('godropme_db', 'children', trip.childId);
    const destination = trip.tripDirection === 'home_to_school' ? 'school' : 'home';
    
    await sendPushNotification(trip.parentId, {
      title: '🏠 Child Dropped Off',
      body: `${child.name} has been safely dropped at ${destination}.`,
      type: 'child_dropped',
      data: { tripId: trip.$id, childId: trip.childId }
    });
    
    await databases.updateDocument('godropme_db', 'trips', trip.$id, {
      droppedNotified: true,
      droppedAt: new Date().toISOString(),
      liveTrackingEnabled: false  // Disable tracking
    });
  }
  
  return res.json({ processed: true });
};
```

### Function 4: `calculate-driver-rating`
> **Trigger**: Event - `databases.godropme_db.collections.ratings.documents.*.create`  
> **Runtime**: Node.js 18+  
> **Purpose**: Update driver's average rating when new rating is added

```javascript
export default async ({ req, res, log }) => {
  const rating = req.body;
  const driverId = rating.driverId;

  const allRatings = await databases.listDocuments('godropme_db', 'ratings', [
    Query.equal('driverId', driverId)
  ]);
  
  const totalRatings = allRatings.total;
  const avgRating = allRatings.documents.reduce((sum, r) => sum + r.rating, 0) / totalRatings;

  await databases.updateDocument('godropme_db', 'drivers', driverId, {
    rating: parseFloat(avgRating.toFixed(2)),
    totalRatings: totalRatings
  });
  
  return res.json({ success: true, newRating: avgRating });
};
```

### Function 5: `match-drivers`
> **Trigger**: HTTP Endpoint (POST /match-drivers)  
> **Runtime**: Node.js 18+  
> **Purpose**: Find suitable drivers for a child based on school and service area polygon

```javascript
// Input: { schoolName, pickupLocation: [lng, lat] }
// Output: List of matching drivers whose service area contains the pickup location

export default async ({ req, res, log }) => {
  const { schoolName, pickupLocation } = JSON.parse(req.body);
  
  // Build query for driver_services
  // Use Appwrite geo query to find drivers whose serviceAreaPolygon contains the pickup point
  const queries = [
    Query.search('schoolNames', schoolName),
    // Spatial query: check if pickupLocation is within serviceAreaPolygon
    Query.contains('serviceAreaPolygon', pickupLocation)
  ];
  
  const driverServices = await databases.listDocuments('godropme_db', 'driver_services', queries);
  
  // Get driver details and calculate distance from service center
  const matchedDrivers = [];
  
  for (const config of driverServices.documents) {
    const driver = await databases.getDocument('godropme_db', 'drivers', config.driverId);
    
    // Only verified drivers
    if (driver.verificationStatus !== 'verified') continue;
    
    // Calculate distance from driver's service area center to pickup location
    const distance = calculateHaversineDistance(config.serviceAreaCenter, pickupLocation);
    
    const vehicle = await databases.getDocument('godropme_db', 'vehicles', config.driverId);
    
    matchedDrivers.push({
      driverId: driver.$id,
      driverName: driver.fullName,
      profilePhotoFileId: driver.profilePhotoFileId,
      rating: driver.rating,
      totalTrips: driver.totalTrips,
      vehicleType: vehicle.vehicleType,
      vehicleModel: `${vehicle.brand} ${vehicle.model}`,
      seatCapacity: vehicle.seatCapacity,
      pricePerMonth: config.pricePerMonth,
      distanceKm: (distance / 1000).toFixed(1),
      serviceRadiusKm: config.serviceAreaRadiusKm
    });
  }
  
  // Sort by distance (closest first), then by rating
  matchedDrivers.sort((a, b) => {
    if (a.distanceKm !== b.distanceKm) return parseFloat(a.distanceKm) - parseFloat(b.distanceKm);
    return b.rating - a.rating;
  });
  
  return res.json({ drivers: matchedDrivers, total: matchedDrivers.length });
};
```

### Function 6: `send-push-notification`
> **Trigger**: HTTP Endpoint (POST /send-notification)  
> **Runtime**: Node.js 18+  
> **Purpose**: Send push notification via Appwrite Messaging (FCM)

```javascript
export default async ({ req, res, log }) => {
  const { userId, title, body, type, data } = JSON.parse(req.body);
  
  // Get user to find FCM token
  const user = await databases.listDocuments('godropme_db', 'users', [
    Query.equal('$id', userId)
  ]);
  
  if (!user.documents.length || !user.documents[0].fcmToken) {
    return res.json({ success: false, error: 'No FCM token' });
  }
  
  // Send via Appwrite Messaging
  const message = await messaging.createPush(
    ID.unique(),                              // messageId
    title,                                     // title
    body,                                      // body
    [],                                        // topics (empty)
    [userId],                                  // users
    [],                                        // targets
    JSON.stringify(data),                      // data payload
    type,                                      // action
    null,                                      // icon
    null,                                      // sound
    null,                                      // color
    null,                                      // tag
    null,                                      // badge
    false,                                     // draft
    null                                       // scheduledAt
  );
  
  // Log notification in database
  await databases.createDocument('godropme_db', 'notifications', ID.unique(), {
    userId: userId,
    targetRole: user.documents[0].role,
    title: title,
    body: body,
    type: type,
    data: JSON.stringify(data),
    isRead: false
  });
  
  return res.json({ success: true, messageId: message.$id });
};
```

### Function 7: `cleanup-old-data`
> **Trigger**: CRON (Weekly - Sunday 2:00 AM)  
> **Runtime**: Node.js 18+  
> **Purpose**: Cleanup old notifications and completed trips

```javascript
export default async ({ req, res, log }) => {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  
  // Delete read notifications older than 30 days
  const oldNotifications = await databases.listDocuments('godropme_db', 'notifications', [
    Query.equal('isRead', true),
    Query.lessThan('$createdAt', thirtyDaysAgo.toISOString())
  ]);
  
  for (const notification of oldNotifications.documents) {
    await databases.deleteDocument('godropme_db', 'notifications', notification.$id);
  }
  
  // Delete geofence_events older than 30 days
  const oldEvents = await databases.listDocuments('godropme_db', 'geofence_events', [
    Query.lessThan('$createdAt', thirtyDaysAgo.toISOString())
  ]);
  
  for (const event of oldEvents.documents) {
    await databases.deleteDocument('godropme_db', 'geofence_events', event.$id);
  }
  
  return res.json({ 
    success: true, 
    deletedNotifications: oldNotifications.total,
    deletedEvents: oldEvents.total 
  });
};
```

### Function 8: `generate-daily-analytics`
> **Trigger**: CRON (Daily at **11:59 PM PKT** — `59 23 * * *` in Asia/Karachi)  
> **Runtime**: Node.js 18+  
> **Purpose**: Generate daily analytics summary and archive trip history

```javascript
// Input: None (CRON triggered)
// Output: Created analytics document

export default async ({ req, res, log }) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0); // Start of today
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  
  // Get all trips for today
  const todaysTrips = await databases.listDocuments('godropme_db', 'trips', [
    Query.greaterThanEqual('scheduledDate', today.toISOString()),
    Query.lessThan('scheduledDate', tomorrow.toISOString())
  ]);
  
  const trips = todaysTrips.documents;
  
  // Calculate metrics
  const morningTrips = trips.filter(t => t.tripType === 'morning');
  const afternoonTrips = trips.filter(t => t.tripType === 'afternoon');
  const completedMorning = morningTrips.filter(t => t.status === 'dropped').length;
  const completedAfternoon = afternoonTrips.filter(t => t.status === 'dropped').length;
  const cancelledTrips = trips.filter(t => t.status === 'cancelled').length;
  const absentChildren = trips.filter(t => t.status === 'absent').length;
  const noShowTrips = trips.filter(t => t.status === 'no_show').length;
  
  // Calculate average delays and durations
  const completedTrips = trips.filter(t => t.status === 'dropped' && t.pickedAt && t.droppedAt);
  let avgPickupDelay = null;
  let avgTripDuration = null;
  
  if (completedTrips.length > 0) {
    const delays = completedTrips
      .filter(t => t.arrivedAt)
      .map(t => {
        const scheduled = new Date(`${t.scheduledDate.split('T')[0]}T${t.windowStartTime}:00`);
        const actual = new Date(t.arrivedAt);
        return (actual - scheduled) / (1000 * 60); // Minutes
      });
    
    if (delays.length > 0) {
      avgPickupDelay = delays.reduce((a, b) => a + b, 0) / delays.length;
    }
    
    const durations = completedTrips.map(t => {
      const picked = new Date(t.pickedAt);
      const dropped = new Date(t.droppedAt);
      return (dropped - picked) / (1000 * 60); // Minutes
    });
    
    avgTripDuration = durations.reduce((a, b) => a + b, 0) / durations.length;
  }
  
  // Count unique drivers
  const uniqueDrivers = new Set(trips.map(t => t.driverId)).size;
  
  // Get service requests created today
  const todaysRequests = await databases.listDocuments('godropme_db', 'service_requests', [
    Query.greaterThanEqual('$createdAt', today.toISOString()),
    Query.lessThan('$createdAt', tomorrow.toISOString())
  ]);
  
  const acceptedRequests = todaysRequests.documents.filter(r => r.status === 'accepted').length;
  const rejectedRequests = todaysRequests.documents.filter(r => r.status === 'rejected').length;
  
  // Get notification count
  const todaysNotifications = await databases.listDocuments('godropme_db', 'notifications', [
    Query.greaterThanEqual('$createdAt', today.toISOString()),
    Query.lessThan('$createdAt', tomorrow.toISOString())
  ]);
  
  // Get geofence events count
  const todaysGeofenceEvents = await databases.listDocuments('godropme_db', 'geofence_events', [
    Query.greaterThanEqual('$createdAt', today.toISOString()),
    Query.lessThan('$createdAt', tomorrow.toISOString())
  ]);
  
  // Get active services count
  const activeServices = await databases.listDocuments('godropme_db', 'active_services', [
    Query.equal('status', 'active')
  ]);
  
  // Get reports filed today
  const todaysReports = await databases.listDocuments('godropme_db', 'reports', [
    Query.greaterThanEqual('$createdAt', today.toISOString()),
    Query.lessThan('$createdAt', tomorrow.toISOString())
  ]);
  
  // Create analytics document
  await databases.createDocument('godropme_db', 'daily_analytics', ID.unique(), {
    date: today.toISOString(),
    totalActiveServices: activeServices.total,
    totalMorningTrips: morningTrips.length,
    totalAfternoonTrips: afternoonTrips.length,
    completedMorningTrips: completedMorning,
    completedAfternoonTrips: completedAfternoon,
    cancelledTrips: cancelledTrips,
    absentChildren: absentChildren,
    noShowTrips: noShowTrips,
    avgPickupDelayMins: avgPickupDelay ? parseFloat(avgPickupDelay.toFixed(1)) : null,
    avgTripDurationMins: avgTripDuration ? parseFloat(avgTripDuration.toFixed(1)) : null,
    activeDrivers: uniqueDrivers,
    newServiceRequests: todaysRequests.total,
    acceptedRequests: acceptedRequests,
    rejectedRequests: rejectedRequests,
    totalNotificationsSent: todaysNotifications.total,
    geofenceEventsCount: todaysGeofenceEvents.total,
    issuesReported: todaysReports.total
  });
  
  // Archive completed trips to trip_history
  for (const trip of completedTrips) {
    await databases.createDocument('godropme_db', 'trip_history', ID.unique(), {
      tripId: trip.$id,
      driverId: trip.driverId,
      childId: trip.childId,
      parentId: trip.parentId,
      activeServiceId: trip.activeServiceId,
      tripType: trip.tripType,
      tripDirection: trip.tripDirection,
      scheduledDate: trip.scheduledDate,
      status: 'completed',
      driverEnrouteAt: trip.driverEnrouteAt || null,
      arrivedAt: trip.arrivedAt || null,
      pickedAt: trip.pickedAt || null,
      droppedAt: trip.droppedAt || null,
      tripDurationMins: trip.pickedAt && trip.droppedAt 
        ? Math.round((new Date(trip.droppedAt) - new Date(trip.pickedAt)) / (1000 * 60))
        : null
    });
  }
  
  log(`Analytics generated for ${today.toDateString()}: ${trips.length} trips, ${completedMorning + completedAfternoon} completed`);
  
  return res.json({ 
    success: true, 
    date: today.toISOString(),
    totalTrips: trips.length,
    completedTrips: completedMorning + completedAfternoon,
    archivedToHistory: completedTrips.length
  });
};
```

### Function 9: `archive-trip-to-history`
> **Trigger**: Event - `databases.godropme_db.collections.trips.documents.*.update`  
> **Runtime**: Node.js 18+  
> **Purpose**: Archive trip to history when it reaches terminal state

```javascript
export default async ({ req, res, log }) => {
  const trip = req.body;
  
  // Only process terminal states
  const terminalStates = ['dropped', 'cancelled', 'absent', 'no_show'];
  if (!terminalStates.includes(trip.status)) {
    return res.json({ skipped: true, reason: 'Not terminal state' });
  }
  
  // Check if already archived
  const existing = await databases.listDocuments('godropme_db', 'trip_history', [
    Query.equal('tripId', trip.$id)
  ]);
  
  if (existing.total > 0) {
    return res.json({ skipped: true, reason: 'Already archived' });
  }
  
  // Calculate trip duration
  let tripDurationMins = null;
  if (trip.pickedAt && trip.droppedAt) {
    tripDurationMins = Math.round((new Date(trip.droppedAt) - new Date(trip.pickedAt)) / (1000 * 60));
  }
  
  // Calculate pickup delay
  let pickupDelayMins = null;
  if (trip.arrivedAt && trip.windowStartTime) {
    const scheduled = new Date(`${trip.scheduledDate.split('T')[0]}T${trip.windowStartTime}:00`);
    const actual = new Date(trip.arrivedAt);
    pickupDelayMins = Math.round((actual - scheduled) / (1000 * 60));
  }
  
  // Create history record
  await databases.createDocument('godropme_db', 'trip_history', ID.unique(), {
    tripId: trip.$id,
    driverId: trip.driverId,
    childId: trip.childId,
    parentId: trip.parentId,
    activeServiceId: trip.activeServiceId,
    tripType: trip.tripType,
    tripDirection: trip.tripDirection,
    scheduledDate: trip.scheduledDate,
    status: trip.status === 'dropped' ? 'completed' : trip.status,
    driverEnrouteAt: trip.driverEnrouteAt || null,
    arrivedAt: trip.arrivedAt || null,
    pickedAt: trip.pickedAt || null,
    droppedAt: trip.droppedAt || null,
    pickupDelayMins: pickupDelayMins,
    tripDurationMins: tripDurationMins
  });
  
  log(`Trip ${trip.$id} archived to history with status: ${trip.status}`);
  
  return res.json({ success: true, archived: true, tripId: trip.$id });
};
```

---

## 🔄 Appwrite Realtime Subscriptions

### Overview: Real-Time Features Using Appwrite Realtime

GoDropMe uses Appwrite Realtime (WebSocket) for three core real-time features:
1. **Driver Location Tracking** - Parent sees driver moving on map during trips
2. **Chat Messages** - Instant message delivery between parent and driver
3. **Trip Status Updates** - Real-time notifications when trip status changes

All three features use the same Appwrite Realtime infrastructure - **no separate service needed**.

---

### 🚗 Real-Time Driver Location Tracking

#### Architecture Flow
```
┌─────────────────────────────────────────────────────────────────────────┐
│                        DRIVER LOCATION TRACKING                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────┐         Appwrite Realtime          ┌─────────────┐     │
│  │ Driver App  │◄───────────────────────────────────►│ Parent App  │     │
│  │             │         (WebSocket)                 │             │     │
│  │ Geolocator  │                                     │ GoogleMap   │     │
│  │     ↓       │                                     │     ↑       │     │
│  │ Position    │                                     │ Marker      │     │
│  └──────┬──────┘                                     └──────┬──────┘     │
│         │                                                    │           │
│         │  Update every 5-10 seconds                        │           │
│         ▼                                                    ▼           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                      Appwrite Cloud                              │    │
│  │  ┌─────────────────────────────────────────────────────────┐    │    │
│  │  │   drivers collection                                     │    │    │
│  │  │   ─────────────────                                      │    │    │
│  │  │   • $id: "driver123"                                     │    │    │
│  │  │   • currentLocation: [71.5249, 34.0151]  ← Updated       │    │    │
│  │  │   • lastLocationUpdate: "2025-11-28T10:30:00Z"           │    │    │
│  │  │   • isOnline: true                                       │    │    │
│  │  └─────────────────────────────────────────────────────────┘    │    │
│  │                           │                                      │    │
│  │                           ▼                                      │    │
│  │  ┌─────────────────────────────────────────────────────────┐    │    │
│  │  │   Realtime Engine                                        │    │    │
│  │  │   ─────────────────                                      │    │    │
│  │  │   Broadcasts to all subscribers:                         │    │    │
│  │  │   "databases.godropme_db.collections.drivers.documents   │    │    │
│  │  │    .driver123.update"                                    │    │    │
│  │  └─────────────────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

#### Driver Side - Broadcasting Location

```dart
// lib/services/driver_location_service.dart

import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  final Databases _databases;
  final String _driverId;
  StreamSubscription<Position>? _positionStream;
  Timer? _updateTimer;
  Position? _lastPosition;
  
  DriverLocationService({
    required Client client,
    required String driverId,
  }) : _databases = Databases(client),
       _driverId = driverId;
  
  /// Start broadcasting location when driver goes online or starts a trip
  void startBroadcasting({
    Duration interval = const Duration(seconds: 5),
    int distanceFilter = 10, // meters - only update if moved 10m+
  }) {
    // Listen to position stream
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    ).listen((position) {
      _lastPosition = position;
    });
    
    // Update Appwrite every N seconds (not on every position change)
    _updateTimer = Timer.periodic(interval, (_) => _pushLocationUpdate());
  }
  
  Future<void> _pushLocationUpdate() async {
    if (_lastPosition == null) return;
    
    try {
      await _databases.updateDocument(
        databaseId: 'godropme_db',
        collectionId: 'drivers',
        documentId: _driverId,
        data: {
          'currentLocation': [
            _lastPosition!.longitude,
            _lastPosition!.latitude,
          ], // Appwrite point format: [lng, lat]
          'lastLocationUpdate': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      // Handle error (retry logic, offline queue, etc.)
      print('Failed to update location: $e');
    }
  }
  
  /// Stop broadcasting when driver goes offline
  void stopBroadcasting() {
    _positionStream?.cancel();
    _positionStream = null;
    _updateTimer?.cancel();
    _updateTimer = null;
  }
  
  /// Call this when driver explicitly goes offline
  Future<void> goOffline() async {
    stopBroadcasting();
    try {
      await _databases.updateDocument(
        databaseId: 'godropme_db',
        collectionId: 'drivers',
        documentId: _driverId,
        data: {
          'isOnline': false,
          'currentLocation': null, // Clear location when offline
        },
      );
    } catch (e) {
      print('Failed to set offline: $e');
    }
  }
}

// Usage in DriverHomeController
class DriverHomeController extends GetxController {
  late DriverLocationService _locationService;
  
  @override
  void onInit() {
    super.onInit();
    _locationService = DriverLocationService(
      client: AppwriteClient.client,
      driverId: currentDriverId,
    );
  }
  
  void goOnline() {
    _locationService.startBroadcasting();
    // Update isOnline flag
  }
  
  void goOffline() {
    _locationService.goOffline();
  }
  
  @override
  void onClose() {
    _locationService.stopBroadcasting();
    super.onClose();
  }
}
```

#### Parent Side - Subscribing to Driver Location

```dart
// lib/services/driver_tracking_service.dart

import 'package:appwrite/appwrite.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverTrackingService {
  final Realtime _realtime;
  RealtimeSubscription? _subscription;
  
  DriverTrackingService(Client client) : _realtime = Realtime(client);
  
  /// Subscribe to a specific driver's location updates
  void subscribeToDriver({
    required String driverId,
    required void Function(LatLng location) onLocationUpdate,
    void Function()? onDriverOffline,
  }) {
    // Subscribe to the specific driver document
    _subscription = _realtime.subscribe([
      'databases.godropme_db.collections.drivers.documents.$driverId'
    ]);
    
    _subscription!.stream.listen((response) {
      // Check if this is an update event
      if (response.events.any((e) => e.contains('.update'))) {
        final payload = response.payload;
        
        // Check if driver went offline
        if (payload['isOnline'] == false) {
          onDriverOffline?.call();
          return;
        }
        
        // Extract location
        final location = payload['currentLocation'];
        if (location != null && location is List && location.length >= 2) {
          // Convert from [lng, lat] to LatLng(lat, lng)
          final driverLatLng = LatLng(
            (location[1] as num).toDouble(),
            (location[0] as num).toDouble(),
          );
          onLocationUpdate(driverLatLng);
        }
      }
    });
  }
  
  void unsubscribe() {
    _subscription?.close();
    _subscription = null;
  }
}

// Usage in ParentMapController
class ParentMapController extends GetxController {
  final driverMarker = Rxn<Marker>();
  final isTracking = false.obs;
  DriverTrackingService? _trackingService;
  
  void startTrackingDriver(String driverId) {
    _trackingService = DriverTrackingService(AppwriteClient.client);
    isTracking.value = true;
    
    _trackingService!.subscribeToDriver(
      driverId: driverId,
      onLocationUpdate: (location) {
        // Update marker on map
        driverMarker.value = Marker(
          markerId: const MarkerId('driver'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Driver'),
        );
      },
      onDriverOffline: () {
        Get.snackbar('Driver Offline', 'The driver has gone offline');
        stopTracking();
      },
    );
  }
  
  void stopTracking() {
    _trackingService?.unsubscribe();
    _trackingService = null;
    driverMarker.value = null;
    isTracking.value = false;
  }
  
  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }
}
```

---

### Parent Real-Time Driver Tracking (During Trips)
```dart
// In Flutter - Parent tracking driver location on map
import 'package:appwrite/appwrite.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripTrackingService {
  final Realtime _realtime;
  RealtimeSubscription? _tripSubscription;
  
  TripTrackingService(Client client) : _realtime = Realtime(client);
  
  /// Subscribe to a specific trip for real-time driver location updates
  void subscribeToTrip({
    required String tripId,
    required Function(LatLng driverLocation, String status) onLocationUpdate,
    required Function() onTripCompleted,
  }) {
    _tripSubscription = _realtime.subscribe([
      'databases.godropme_db.collections.trips.documents.$tripId'
    ]);
    
    _tripSubscription!.stream.listen((response) {
      if (response.events.contains('databases.*.collections.*.documents.*.update')) {
        final tripData = response.payload;
        
        // Check if trip is completed
        if (tripData['status'] == 'dropped') {
          onTripCompleted();
          unsubscribe();
          return;
        }
        
        // Update driver location on map
        if (tripData['currentDriverLocation'] != null && 
            tripData['liveTrackingEnabled'] == true) {
          final location = tripData['currentDriverLocation'] as List;
          final driverLatLng = LatLng(location[1], location[0]); // [lng, lat] → LatLng(lat, lng)
          
          onLocationUpdate(driverLatLng, tripData['status']);
        }
      }
    });
  }
  
  void unsubscribe() {
    _tripSubscription?.close();
    _tripSubscription = null;
  }
}

// Usage in Parent Map Screen
class ParentMapScreenController extends GetxController {
  final tripTrackingService = TripTrackingService(AppwriteClient.client);
  final driverMarker = Rxn<Marker>();
  final tripStatus = ''.obs;
  
  void startTracking(String tripId) {
    tripTrackingService.subscribeToTrip(
      tripId: tripId,
      onLocationUpdate: (driverLocation, status) {
        // Update marker on map
        driverMarker.value = Marker(
          markerId: MarkerId('driver'),
          position: driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Driver', snippet: status),
        );
        tripStatus.value = status;
        
        // Animate camera to driver
        mapController?.animateCamera(CameraUpdate.newLatLng(driverLocation));
      },
      onTripCompleted: () {
        Get.snackbar('Trip Completed', 'Your child has been safely dropped off');
        driverMarker.value = null;
      },
    );
  }
  
  @override
  void onClose() {
    tripTrackingService.unsubscribe();
    super.onClose();
  }
}
```

### Driver Location Broadcasting (During Trips)
```dart
// Driver app - Update location periodically during active trip
class DriverLocationService {
  final Databases _databases;
  Timer? _locationTimer;
  
  DriverLocationService(Client client) : _databases = Databases(client);
  
  /// Start broadcasting location for an active trip
  void startBroadcasting(String tripId) {
    // Update every 5 seconds
    _locationTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      final position = await Geolocator.getCurrentPosition();
      
      await _databases.updateDocument(
        databaseId: 'godropme_db',
        collectionId: 'trips',
        documentId: tripId,
        data: {
          'currentDriverLocation': [position.longitude, position.latitude], // [lng, lat]
        },
      );
    });
  }
  
  void stopBroadcasting() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }
}
```

### Chat Messages (Real-time):
```dart
// Subscribe to new messages in a chat room
class ChatService {
  final Realtime _realtime;
  RealtimeSubscription? _messageSubscription;
  
  ChatService(Client client) : _realtime = Realtime(client);
  
  void subscribeToMessages({
    required String chatRoomId,
    required Function(Map<String, dynamic> message) onNewMessage,
  }) {
    _messageSubscription = _realtime.subscribe([
      'databases.godropme_db.collections.messages.documents'
    ]);
    
    _messageSubscription!.stream.listen((response) {
      if (response.events.contains('databases.*.collections.*.documents.*.create')) {
        final message = response.payload;
        
        // Only process messages for this chat room
        if (message['chatRoomId'] == chatRoomId) {
          onNewMessage(message);
        }
      }
    });
  }
  
  void unsubscribe() {
    _messageSubscription?.close();
  }
}
```

### Trip Status Notifications (Real-time for Parent):
```dart
// Subscribe to ALL trips for a parent (for dashboard/notifications)
class ParentTripsService {
  final Realtime _realtime;
  RealtimeSubscription? _tripsSubscription;
  
  ParentTripsService(Client client) : _realtime = Realtime(client);
  
  void subscribeToParentTrips({
    required String parentId,
    required Function(Map<String, dynamic> trip, String eventType) onTripUpdate,
  }) {
    _tripsSubscription = _realtime.subscribe([
      'databases.godropme_db.collections.trips.documents'
    ]);
    
    _tripsSubscription!.stream.listen((response) {
      final trip = response.payload;
      
      // Only process trips for this parent
      if (trip['parentId'] != parentId) return;
      
      if (response.events.contains('databases.*.collections.*.documents.*.create')) {
        onTripUpdate(trip, 'created');
      } else if (response.events.contains('databases.*.collections.*.documents.*.update')) {
        onTripUpdate(trip, 'updated');
        
        // Show in-app notifications based on status
        switch (trip['status']) {
          case 'driver_enroute':
            _showNotification('Driver Started', 'Driver is on the way!');
            break;
          case 'arrived':
            _showNotification('Driver Arrived', 'Driver has arrived at pickup location');
            break;
          case 'picked':
            _showNotification('Child Picked Up', 'Your child is now with the driver');
            break;
          case 'dropped':
            _showNotification('Trip Complete', 'Your child has been safely dropped off');
            break;
        }
      }
    });
  }
  
  void _showNotification(String title, String message) {
    Get.snackbar(title, message, duration: Duration(seconds: 3));
  }
  
  void unsubscribe() {
    _tripsSubscription?.close();
  }
}
```

---

## ✅ Development TODO List

### Phase 1: Appwrite Setup & Authentication 🔐 ✅ COMPLETED
> **Priority**: HIGH | **Estimated**: 2-3 days

- [ ] **1.1** Create Appwrite Database `godropme_db` in console
- [ ] **1.2** Create `users` collection with all attributes
- [ ] **1.3** Create `database_constants.dart` with all IDs
  ```dart
  class DatabaseConstants {
    static const String databaseId = 'godropme_db';
    static const String usersCollection = 'users';
    // ... all collection IDs
  }
  ```
- [ ] **1.4** Create `auth_service.dart`
  - [ ] `sendEmailOTP(email)` → `account.createEmailToken()`
  - [ ] `verifyOTP(userId, otp)` → `account.createSession()`
  - [ ] `getCurrentUser()` → `account.get()`
  - [ ] `getCurrentSession()` → `account.getSession('current')`
  - [ ] `logout()` → `account.deleteSession('current')`
  - [ ] `isLoggedIn()` → Check session exists
- [ ] **1.5** Update `EmailController` for OTP sending
- [x] **1.6** Update `OtpController` for OTP verification
- [ ] **1.7** Create `user_service.dart` for user document CRUD
- [x] **1.8** Add Realtime client helper to `appwrite_client.dart`
- [x] **1.9** Handle session persistence on app restart
- [ ] **1.10** Create auth middleware for protected routes

---

### Phase 2: Parent Registration 👨‍👩‍👧 ✅ COMPLETED
> **Priority**: HIGH | **Completed**: December 2, 2025

- [x] **2.1** Create `parents` collection in Appwrite
- [x] **2.2** Create `children` collection in Appwrite
- [x] **2.3** Create storage buckets: `profile_photos`, `child_photos`
- [x] **2.4** Create `storage_service.dart`
  - [x] `uploadFile(bucketId, file)` → Returns file ID
  - [x] `getFilePreview(bucketId, fileId)`
  - [x] `deleteFile(bucketId, fileId)`
  - [x] `compressImage(file)` → Compress before upload (max 1MB)
- [x] **2.5** Create `parent_service.dart`
  - [x] `createParent(data)`
  - [x] `getParent(userId)`
  - [x] `updateParent(parentId, data)`
  - [x] `uploadProfilePhoto(file)` → Returns file ID
- [x] **2.6** Create `child_service.dart`
  - [x] `addChild(parentId, childData)`
  - [x] `getChildren(parentId)`
  - [x] `updateChild(childId, data)`
  - [x] `deleteChild(childId)`
- [x] **2.7** Update `ParentNameScreen` controller
- [x] **2.8** Update `AddChildrenScreen` controller
- [x] **2.9** Sync local drafts with Appwrite on submit

**⚠️ LESSON LEARNED - Document ID Strategy:**
- DON'T add `authUserId` column to `users` table
- DO use Auth User ID AS the document ID: `documentId: authUserId`
- This applies to: `users` collection only
- Other collections use `ID.unique()` + foreign key columns

---

### Phase 3: Driver Registration 🚗 ✅ COMPLETED
> **Priority**: HIGH | **Estimated**: 4-5 days

- [ ] **3.1** Create `drivers` collection 
- [ ] **3.2** Create `vehicles` collection 
- [ ] **3.3** Create `driver_services` collection 
- [ ] **3.4** Create storage buckets: `documents`, `vehicle_photos` 
- [ ] **3.5** Create `driver_service.dart`
  - [ ] `createDriver(data)`
  - [ ] `getDriver(userId)`
  - [ ] `updateDriver(driverId, data)`
  - [ ] `uploadDocument(file, type)` → CNIC, License, etc.
  - [ ] `updateLocation(driverId, point)`
  - [ ] `setOnlineStatus(driverId, isOnline)`
- [ ] **3.6** Create `vehicle_service.dart`
  - [ ] `createVehicle(driverId, data)`
  - [ ] `getVehicle(driverId)`
  - [ ] `updateVehicle(vehicleId, data)`
- [ ] **3.7** Create `driver_config_service.dart`
  - [ ] `createServiceConfig(driverId, data)`
  - [ ] `getServiceConfig(driverId)`
  - [ ] `updateServiceConfig(configId, data)`
- [ ] **3.8** Update all driver registration screen controllers:
  - [ ] `DriverNameScreen`
  - [ ] `VehicleSelectionScreen`
  - [ ] `PersonalInfoScreen`
  - [ ] `DriverLicenceScreen`
  - [ ] `DriverIdentificationScreen`
  - [ ] `VehicleRegistrationScreen`
  - [ ] `ServiceDetailsScreen`
- [ ] **3.9** Implement step-by-step draft persistence
- [ ] **3.10** Image compression before upload (max 1MB)

---

### Phase 4: Service Requests & Matching 🔍
> **Priority**: HIGH | **Estimated**: 3-4 days

- [ ] **4.1** Create `service_requests` collection ✅ (already exists)
- [ ] **4.2** Create `active_services` collection ✅ (already exists)
- [ ] **4.3** Create Appwrite Function: `match-drivers`
- [ ] **4.4** Create `service_request_service.dart`
  - [ ] `sendRequest(parentId, driverId, childId, data)`
  - [ ] `getParentRequests(parentId)`
  - [ ] `getDriverRequests(driverId)`
  - [ ] `acceptRequest(requestId)`
  - [ ] `rejectRequest(requestId, message)`
  - [ ] `cancelRequest(requestId)`
- [ ] **4.5** Create `active_service_service.dart`
  - [ ] `createActiveService(requestId)`
  - [ ] `getActiveServices(parentId/driverId)`
  - [ ] `pauseService(serviceId)`
  - [ ] `endService(serviceId)`
- [ ] **4.6** Update `FindDriversScreen` with real data
  - [ ] Geo query for nearby drivers
  - [ ] Filter by school, service type
  - [ ] Show driver ratings
- [ ] **4.7** Implement request flow UI

---

### Phase 5: Trips & Geofencing 📍
> **Priority**: HIGH | **Estimated**: 4-5 days

- [ ] **5.1** Create `trips` collection ✅ (already exists)
- [ ] **5.2** Create `geofence_events` collection ✅ (already exists)
- [ ] **5.3** Create Appwrite Function: `generate-daily-trips`
- [ ] **5.4** Create Appwrite Function: `process-geofence`
- [ ] **5.5** Create `trip_service.dart`
  - [ ] `getTodayTrips(driverId)`
  - [ ] `getParentTrips(parentId)`
  - [ ] `startTrip(tripId)` → status: driver_enroute
  - [ ] `markArrived(tripId)`
  - [ ] `markPicked(tripId)`
  - [ ] `markDropped(tripId)`
  - [ ] `markAbsent(tripId, reason)`
  - [ ] `updateDriverLocation(tripId, point)`
  - [ ] `confirmDrop(tripId)` → parent confirmation
- [ ] **5.6** Create `geofence_service.dart`
  - [ ] `checkGeofence(driverLocation, targetLocation)`
  - [ ] `logGeofenceEvent(tripId, eventType, location)`
- [ ] **5.7** Update `DriverHomeScreen`
  - [ ] Show today's trips
  - [ ] Update trip status
  - [ ] Real-time location sharing
- [ ] **5.8** Update `ParentMapScreen`
  - [ ] Track driver in real-time
  - [ ] Show trip status
  - [ ] Confirm drop-off
- [ ] **5.9** Implement geofence notifications
  - [ ] "Driver is approaching" (500m)
  - [ ] "Driver has arrived" (100m)
  - [ ] "Child picked up"
  - [ ] "Child dropped off"

---

### Phase 6: Real-time Chat 💬
> **Priority**: MEDIUM | **Estimated**: 3-4 days

- [ ] **6.1** Create `chat_rooms` collection ✅ (already exists)
- [ ] **6.2** Create `messages` collection ✅ (already exists)
- [ ] **6.3** Create storage bucket: `chat_attachments`
- [ ] **6.4** Create `chat_service.dart`
  - [ ] `getOrCreateChatRoom(parentId, driverId)`
  - [ ] `getChatRooms(userId, role)`
  - [ ] `sendMessage(roomId, senderId, role, text)`
  - [ ] `sendImage(roomId, senderId, role, file)`
  - [ ] `sendLocation(roomId, senderId, role, point)`
  - [ ] `getMessages(roomId)`
  - [ ] `markAsRead(roomId, userId)`
- [ ] **6.5** Create `realtime_service.dart`
  - [ ] `subscribeToMessages(chatRoomId, callback)`
  - [ ] `subscribeToTripUpdates(tripId, callback)`
  - [ ] `subscribeToChatRooms(userId, callback)`
  - [ ] `unsubscribe(subscriptionId)`
- [ ] **6.6** Update `ParentChatScreen` - chat list
- [ ] **6.7** Update `ParentConversationScreen` - messages
- [ ] **6.8** Update `DriverConversationScreen` - messages
- [ ] **6.9** Implement unread badges (real-time)
- [ ] **6.10** Message read receipts

---

### Phase 7: Push Notifications 🔔
> **Priority**: MEDIUM | **Estimated**: 3 days

- [ ] **7.1** Create `notifications` collection ✅ (already exists)
- [ ] **7.2** Setup Firebase Cloud Messaging (FCM)
- [ ] **7.3** Configure Appwrite Messaging provider (FCM)
- [ ] **7.4** Create Appwrite Function: `send-push-notification`
- [ ] **7.5** Create `notification_service.dart`
  - [ ] `registerFCMToken(userId, token)`
  - [ ] `getNotifications(userId)`
  - [ ] `markAsRead(notificationId)`
  - [ ] `markAllAsRead(userId)`
  - [ ] `clearAll(userId)`
- [ ] **7.6** Implement notification triggers:
  - [ ] Service request received (driver)
  - [ ] Request accepted/rejected (parent)
  - [ ] Driver approaching (parent)
  - [ ] Driver arrived (parent)
  - [ ] Child picked up (parent)
  - [ ] Child dropped off (parent)
  - [ ] New message (both)
- [ ] **7.7** Update `ParentsNotificationScreen`
- [ ] **7.8** Update `DriverNotificationsScreen`
- [ ] **7.9** Handle notification tap navigation

---

### Phase 8: Ratings & Reports ⭐
> **Priority**: LOW | **Estimated**: 2-3 days

- [ ] **8.1** Create `ratings` collection ✅ (already exists)
- [ ] **8.2** Create `reports` collection ✅ (already exists)
- [ ] **8.3** Create storage bucket: `report_attachments`
- [ ] **8.4** Create Appwrite Function: `calculate-driver-rating`
- [ ] **8.5** Create `rating_service.dart`
  - [ ] `rateDriver(driverId, parentId, tripId, rating, review)`
  - [ ] `getDriverRatings(driverId)`
  - [ ] `canRate(parentId, driverId)` → Check if has active service
- [ ] **8.6** Create `report_service.dart`
  - [ ] `submitReport(data)`
  - [ ] `getReports(userId)`
  - [ ] `uploadAttachment(file)`
- [ ] **8.7** Update `ParentReportScreen`
- [ ] **8.8** Update `DriverReportScreen`
- [ ] **8.9** Add rating prompt after trip completion
- [ ] **8.10** Display driver ratings on listing

---

### Phase 9: Profile & Settings ⚙️
> **Priority**: LOW | **Estimated**: 2 days

- [ ] **9.1** Update `ProfileScreen` (Parent)
  - [ ] Display profile data from Appwrite
  - [ ] Edit profile
  - [ ] Change profile photo
- [ ] **9.2** Update `DriverProfileScreen`
  - [ ] Display profile data
  - [ ] Show verification status
  - [ ] Show rating & total trips
- [ ] **9.3** Update `ParentSettingsScreen`
  - [ ] Notification preferences
  - [ ] Privacy settings
- [ ] **9.4** Update `DriverSettingsScreen`
  - [ ] Notification preferences
  - [ ] Online/offline toggle
- [ ] **9.5** Implement account deletion
- [ ] **9.6** Implement logout flow

---

## 📂 Updated Folder Structure

```
lib/services/
├── appwrite/
│   ├── appwrite_client.dart       ✅ Exists (add Realtime, Functions)
│   ├── auth_service.dart          ✅ Created
│   ├── database_constants.dart    ✅ Created
│   ├── storage_service.dart       ✅ Created
│   ├── realtime_service.dart      🔴 Create
│   └── functions_service.dart     🔴 Create
├── user_service.dart              🔴 Create
├── parent_service.dart            ✅ Created
├── child_service.dart             ✅ Created
├── driver_service.dart            ✅ Created
├── vehicle_service.dart           ✅ Created
├── driver_config_service.dart     ✅ Created
├── service_request_service.dart   🔴 Create
├── active_service_service.dart    🔴 Create
├── trip_service.dart              🔴 Create
├── trip_tracking_service.dart     🔴 Create (Realtime driver tracking)
├── geofence_service.dart          🔴 Create
├── chat_service.dart              🔴 Create
├── notification_service.dart      🔴 Create
├── report_service.dart            🔴 Create
├── rating_service.dart            🔴 Create
└── Terms_uri_opener.dart          ✅ Exists
```

---

## 📚 Appwrite Flutter SDK Quick Reference

### Account Service (Authentication)
```dart
import 'package:appwrite/appwrite.dart';

final account = Account(client);

// Email OTP - Step 1: Send token
Token token = await account.createEmailToken(
  userId: ID.unique(),
  email: 'user@example.com',
);
String userId = token.userId;

// Email OTP - Step 2: Verify and create session
Session session = await account.createSession(
  userId: userId,
  secret: '123456', // 6-digit OTP
);

// Get current user
User user = await account.get();

// Get current session
Session session = await account.getSession(sessionId: 'current');

// Logout
await account.deleteSession(sessionId: 'current');

// Delete all sessions (logout everywhere)
await account.deleteSessions();
```

### Databases Service (CRUD Operations)
```dart
import 'package:appwrite/appwrite.dart';

final databases = Databases(client);

// Create document
Document doc = await databases.createDocument(
  databaseId: 'godropme_db',
  collectionId: 'users',
  documentId: ID.unique(),
  data: {
    'email': 'user@example.com',
    'role': 'parent',
    'isProfileComplete': false,
  },
);

// Get document
Document doc = await databases.getDocument(
  databaseId: 'godropme_db',
  collectionId: 'users',
  documentId: 'document_id',
);

// Update document
Document doc = await databases.updateDocument(
  databaseId: 'godropme_db',
  collectionId: 'users',
  documentId: 'document_id',
  data: {
    'isProfileComplete': true,
  },
);

// Upsert (create or update)
Document doc = await databases.upsertDocument(
  databaseId: 'godropme_db',
  collectionId: 'users',
  documentId: 'document_id',
  data: {...},
);

// List documents with queries
DocumentList docs = await databases.listDocuments(
  databaseId: 'godropme_db',
  collectionId: 'drivers',
  queries: [
    Query.equal('verificationStatus', 'verified'),
    Query.equal('isOnline', true),
    Query.limit(25),
    Query.offset(0),
  ],
);

// Delete document
await databases.deleteDocument(
  databaseId: 'godropme_db',
  collectionId: 'users',
  documentId: 'document_id',
);
```

### Storage Service (File Upload/Download)
```dart
import 'package:appwrite/appwrite.dart';

final storage = Storage(client);

// Upload file
File file = await storage.createFile(
  bucketId: 'profile_photos',
  fileId: ID.unique(),
  file: InputFile.fromPath(path: '/path/to/image.jpg', filename: 'profile.jpg'),
);
String fileId = file.$id;

// Get file preview (for images)
Uint8List bytes = await storage.getFilePreview(
  bucketId: 'profile_photos',
  fileId: fileId,
  width: 200,
  height: 200,
  quality: 80,
);

// Get file download URL
Uint8List bytes = await storage.getFileDownload(
  bucketId: 'documents',
  fileId: fileId,
);

// Delete file
await storage.deleteFile(
  bucketId: 'profile_photos',
  fileId: fileId,
);

// Get file metadata
File fileInfo = await storage.getFile(
  bucketId: 'profile_photos',
  fileId: fileId,
);
```

### Functions Service (Execute Functions)
```dart
import 'package:appwrite/appwrite.dart';

final functions = Functions(client);

// Execute function (e.g., match-drivers)
Execution result = await functions.createExecution(
  functionId: 'match-drivers',
  body: jsonEncode({
    'schoolName': 'ABC School',
    'pickupLocation': [71.5249, 34.0151],
    'serviceWindow': 'morning',
  }),
  xasync: false, // Wait for result
  method: ExecutionMethod.pOST,
);

// Parse response
final response = jsonDecode(result.responseBody);
final drivers = response['drivers'] as List;
```

### Realtime Service (Live Updates)
```dart
import 'package:appwrite/appwrite.dart';

final realtime = Realtime(client);

// Subscribe to specific document
RealtimeSubscription subscription = realtime.subscribe([
  'databases.godropme_db.collections.trips.documents.TRIP_ID'
]);

subscription.stream.listen((RealtimeMessage response) {
  final payload = response.payload;
  final events = response.events;
  
  if (events.contains('databases.*.collections.*.documents.*.update')) {
    // Handle update
  }
});

// Subscribe to collection (all documents)
RealtimeSubscription subscription = realtime.subscribe([
  'databases.godropme_db.collections.messages.documents'
]);

// Unsubscribe
subscription.close();
```

### Messaging Service (Push Notifications - Client Side)
```dart
import 'package:appwrite/appwrite.dart';

final messaging = Messaging(client);

// Subscribe to a topic
Subscriber subscriber = await messaging.createSubscriber(
  topicId: 'trip-updates',
  subscriberId: ID.unique(),
  targetId: userId, // Current user ID
);

// Unsubscribe from topic
await messaging.deleteSubscriber(
  topicId: 'trip-updates',
  subscriberId: subscriber.$id,
);
```

---

## 🚀 Appwrite Functions Directory

```
functions/
├── generate-daily-trips/
│   ├── src/
│   │   └── main.js
│   ├── package.json
│   └── .env.example
├── process-geofence/
│   ├── src/
│   │   └── main.js
│   ├── package.json
│   └── .env.example
├── notify-trip-status/
│   ├── src/
│   │   └── main.js
│   ├── package.json
│   └── .env.example
├── calculate-driver-rating/
│   ├── src/
│   │   └── main.js
│   ├── package.json
│   └── .env.example
├── match-drivers/
│   ├── src/
│   │   └── main.js
│   ├── package.json
│   └── .env.example
├── send-push-notification/
│   ├── src/
│   │   └── main.js
│   ├── package.json
│   └── .env.example
└── cleanup-old-data/
    ├── src/
    │   └── main.js
    ├── package.json
    └── .env.example
```

### Functions Summary Table

| Function | Trigger | Runtime | Schedule/Event |
|----------|---------|---------|----------------|
| `generate-morning-trips` | CRON | Node.js 18 | `0 5 * * *` (5:00 AM daily PKT) |
| `generate-afternoon-trips` | CRON | Node.js 18 | `0 11 * * *` (11:00 AM daily PKT) |
| `process-geofence` | Event | Node.js 18 | `databases.godropme_db.collections.trips.documents.*.update` |
| `notify-trip-status` | Event | Node.js 18 | `databases.godropme_db.collections.trips.documents.*.update` |
| `calculate-driver-rating` | Event | Node.js 18 | `databases.godropme_db.collections.ratings.documents.*.create` |
| `match-drivers` | HTTP | Node.js 18 | `POST /v1/functions/{functionId}/executions` |
| `send-push-notification` | HTTP | Node.js 18 | `POST /v1/functions/{functionId}/executions` |
| `cleanup-old-data` | CRON | Node.js 18 | `0 2 * * 0` (Sunday 2:00 AM) |
| `generate-daily-analytics` | CRON | Node.js 18 | `59 23 * * *` (11:59 PM daily PKT) |
| `archive-trip-to-history` | Event | Node.js 18 | `databases.godropme_db.collections.trips.documents.*.update` |

> **Total Functions**: 10 (4 CRON, 4 Event-triggered, 2 HTTP)

---

## 📅 Timeline Estimate

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Phase 1: Auth | 2-3 days | Appwrite console setup |
| Phase 2: Parent Registration | 3-4 days | Phase 1 |
| Phase 3: Driver Registration | 4-5 days | Phase 1 |
| Phase 4: Service Matching | 3-4 days | Phase 2, 3 |
| Phase 5: Trips & Geofencing | 4-5 days | Phase 4, Functions |
| Phase 6: Chat | 3-4 days | Phase 2, 3, Realtime |
| Phase 7: Notifications | 3 days | Phase 5, FCM, Messaging |
| Phase 8: Ratings & Reports | 2-3 days | Phase 5 |
| Phase 9: Profile & Settings | 2 days | Phase 2, 3 |

**Total Estimated Time**: 4-5 weeks

---

## 🎯 Immediate Next Steps

### Step 1: Appwrite Console Setup (Manual)
```
1. Go to https://cloud.appwrite.io/console
2. Select project: 68ed397e000f277c6936
3. Create Database: "godropme_db"
4. Create all 17 collections with attributes (see schema above):
   - users, parents, children, drivers, vehicles, driver_services
   - service_requests, active_services, trips, chat_rooms, messages
   - notifications, reports, geofence_events, daily_analytics, trip_history, ratings
5. Create 6 Storage Buckets (profile_photos, documents, etc.)
6. Configure collection permissions
```

### Step 2: Create Base Service Files (Code)
```
lib/services/appwrite/
├── database_constants.dart   ← All collection/bucket IDs
├── auth_service.dart         ← Email OTP implementation
├── storage_service.dart      ← File upload/download
└── realtime_service.dart     ← Realtime subscriptions
```

### Step 3: Implement Phase 1 - Email OTP Auth
1. Create `auth_service.dart` with:
   - `sendEmailOTP(email)` → Uses `account.createEmailToken()`
   - `verifyOTP(userId, otp)` → Uses `account.createSession()`
   - `getCurrentUser()` → Uses `account.get()`
   - `logout()` → Uses `account.deleteSession('current')`

2. Update `EmailController` (existing):
   - Call `AuthService.sendEmailOTP()`
   - Store returned `userId` for verification

3. Update `OtpController` (existing):
   - Call `AuthService.verifyOTP(userId, otp)`
   - Create user document in `users` collection
   - Navigate to role selection or dashboard

### Step 4: Deploy First Appwrite Function
1. Install Appwrite CLI:
   ```bash
   npm install -g appwrite-cli
   appwrite login
   ```

2. Create `generate-daily-trips` function:
   ```bash
   appwrite functions create
   ```

3. Deploy and test with manual trigger

### Priority Order
1. ✅ TODO.md created with full plan
2. 🔲 Create `database_constants.dart`
3. 🔲 Create `auth_service.dart`
4. 🔲 Update `EmailController` & `OtpController`
5. 🔲 Create `users` collection in Appwrite Console
6. 🔲 Test complete auth flow
7. 🔲 Create parent collections
8. 🔲 Implement parent registration
9. 🔲 Create driver collections
10. 🔲 Implement driver registration

---

## 📝 Important Notes

### Service Windows (Fixed - Pakistan School Timings)
- **Morning Window**: 5:00 AM - 9:00 AM (Home → School)
- **Afternoon Window**: 11:00 AM - 3:00 PM (School → Home)
- Each trip direction reverses pickup/drop locations
- **System-managed**: Drivers don't select windows; trips are auto-generated for both

### Driver-Parent Spatial Matching
- Drivers define a **service area polygon** (center + radius 1-10 km)
- Parents' home location is matched against driver's `serviceAreaPolygon` using Appwrite spatial queries
- Query: Check if parent's `location` point is within driver's `serviceAreaPolygon`

### Appwrite Specifics
- **Auto-generated fields**: `$id`, `$createdAt`, `$updatedAt`
- **Coordinates format**: `[longitude, latitude]` (GeoJSON standard)
- **Distance queries**: Use meters (e.g., 500 for 500m)
- **Geofence triggers**: 500m for "approaching", 100m for "arrived"
- **Realtime**: Re-subscribe after auth changes
- **Relationships**: Max 3 levels of nesting
- **Functions execute from client**: Use `functions.createExecution()`

### Data Formats
- **Phone format**: +92XXXXXXXXXX (E.164)
- **CNIC format**: 13 digits without dashes
- **Time format**: HH:MM (24-hour)
- **Image compression**: Max 1MB before upload

### Real-Time Tracking
- Driver updates location every 5 seconds during active trip
- Parent sees live driver marker on map
- Tracking auto-stops when trip status = 'dropped'
- `liveTrackingEnabled` controls visibility

### Notification Flow
```
Driver Enroute → 🔔 "Driver started route"
500m away → 🔔 "Driver approaching" (geofence)
100m away → 🔔 "Driver arrived" (geofence)
Child picked → 🔔 "Child picked up" (manual trigger)
Child dropped → 🔔 "Child safely dropped" (manual + geofence)
```

---

> **Last Updated**: December 3, 2025  
> **Author**: Development Team
> 
> **Recent Schema Changes (Dec 3, 2025):**
> - Unified status to `users.status` only (removed `drivers.verificationStatus`)
> - Consolidated `suspensionReason` + `rejectionReason` → single `statusReason` column
> - Added `CollectionEnums.statusPending/Active/Suspended/Rejected` constants
