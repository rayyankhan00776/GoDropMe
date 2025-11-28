# 📋 GoDropMe - Backend Development Plan

> **Project**: GoDropMe - School Children Transportation App  
> **Backend**: Appwrite Cloud (fra.cloud.appwrite.io)  
> **Project ID**: `68ed397e000f277c6936`  
> **Created**: November 27, 2025  
> **Status**: Planning Phase

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

### Flow:
```
1. User enters email → account.createEmailToken(userId, email)
   ↓
2. User receives 6-digit OTP via email
   ↓
3. User enters OTP → account.createSession(userId, secret)
   ↓
4. Session created → User authenticated
```

### Key Methods:
```dart
// Step 1: Send OTP
final token = await account.createEmailToken(
  userId: ID.unique(),
  email: 'user@example.com',
);
final userId = token.userId;

// Step 2: Verify OTP and create session  
final session = await account.createSession(
  userId: userId,
  secret: '123456', // 6-digit OTP from email
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

---

### 📁 Collection 1: `users`
> Core user authentication and role management

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `email` | email | ✅ | - | User email (used for OTP auth) |
| `phone` | string(20) | ❌ | null | Phone number (+92XXXXXXXXXX) |
| `role` | enum | ✅ | - | Values: `parent`, `driver` |
| `isProfileComplete` | boolean | ✅ | false | Registration completed |
| `isApproved` | boolean | ✅ | false | Admin approval (for drivers) |
| `status` | enum | ✅ | `pending` | Values: `active`, `suspended`, `pending` |
| `fcmToken` | string(500) | ❌ | null | Push notification token |

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
| `phone` | string(20) | ✅ | - | Phone with country code |
| `email` | email | ✅ | - | Parent's email |
| `profilePhotoFileId` | string(36) | ❌ | null | Storage file ID |
| `address` | string(500) | ❌ | null | Home address |
| `location` | point | ❌ | null | Home coordinates [lng, lat] |

**Indexes**:
- `userId` (Unique)
- `email` (Unique)
- `location` (Key) - For geo queries

**Relationships**:
- One-to-Many → `children` (parent has many children)

---

### 📁 Collection 3: `children`
> Children registered by parents

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `parentId` | relationship | ✅ | - | Many-to-One → `parents` |
| `name` | string(128) | ✅ | - | Child's name |
| `age` | integer | ✅ | - | Age (4-25) |
| `gender` | enum | ✅ | - | Values: `male`, `female` |
| `schoolName` | string(256) | ✅ | - | School name |
| `pickupAddress` | string(500) | ✅ | - | Pickup location address |
| `pickupLocation` | point | ✅ | - | Pickup coordinates [lng, lat] |
| `dropAddress` | string(500) | ✅ | - | Drop-off location address |
| `dropLocation` | point | ✅ | - | Drop-off coordinates [lng, lat] |
| `relationshipToChild` | string(50) | ✅ | - | Father, Mother, Guardian, etc. |
| `pickupTime` | string(10) | ❌ | null | Preferred pickup time (HH:MM) |
| `dropTime` | string(10) | ❌ | null | Preferred drop time (HH:MM) |
| `photoFileId` | string(36) | ❌ | null | Storage file ID |
| `specialNotes` | string(1000) | ❌ | null | Special instructions |
| `isActive` | boolean | ✅ | true | Currently needs service |
| `assignedDriverId` | string(36) | ❌ | null | Reference to drivers.$id |

**Indexes**:
- `parentId` (Key)
- `schoolName` (Key)
- `assignedDriverId` (Key)
- `isActive` (Key)
- `pickupLocation` (Key) - For geo queries
- `dropLocation` (Key) - For geo queries

---

### 📁 Collection 4: `drivers`
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
| `profilePhotoFileId` | string(36) | ✅ | - | Storage file ID |
| `cnicNumber` | string(13) | ✅ | - | 13-digit CNIC (no dashes) |
| `cnicExpiry` | datetime | ❌ | null | CNIC expiry date |
| `cnicFrontFileId` | string(36) | ✅ | - | Storage file ID |
| `cnicBackFileId` | string(36) | ✅ | - | Storage file ID |
| `licenseNumber` | string(50) | ✅ | - | Driving license number |
| `licenseExpiry` | datetime | ✅ | - | License expiry date |
| `licensePhotoFileId` | string(36) | ✅ | - | Storage file ID |
| `selfieWithLicenseFileId` | string(36) | ✅ | - | Storage file ID |
| `verificationStatus` | enum | ✅ | `pending` | Values: `pending`, `verified`, `rejected` |
| `rating` | float | ❌ | 0.0 | Average rating (1-5) |
| `totalTrips` | integer | ❌ | 0 | Total completed trips |
| `totalRatings` | integer | ❌ | 0 | Number of ratings received |
| `isOnline` | boolean | ✅ | false | Currently accepting rides |
| `currentLocation` | point | ❌ | null | Real-time location [lng, lat] |

**Indexes**:
- `userId` (Unique)
- `email` (Unique)
- `cnicNumber` (Unique)
- `licenseNumber` (Unique)
- `verificationStatus` (Key)
- `isOnline` (Key)
- `currentLocation` (Key) - For geo queries & geofencing

---

### 📁 Collection 5: `vehicles`
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
| `vehiclePhotoFileId` | string(36) | ✅ | - | Storage file ID |
| `registrationFrontFileId` | string(36) | ✅ | - | Storage file ID |
| `registrationBackFileId` | string(36) | ✅ | - | Storage file ID |
| `isActive` | boolean | ✅ | true | Currently in use |

**Indexes**:
- `driverId` (Unique)
- `numberPlate` (Unique)
- `vehicleType` (Key)

---

### 📁 Collection 6: `driver_services`
> Driver's service configuration

> **Note**: Service windows are **system-managed** (Morning: 5-9 AM → home_to_school, Afternoon: 11 AM-3 PM → school_to_home). Drivers don't select windows — trips are auto-generated for both.

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `driverId` | relationship | ✅ | - | One-to-One → `drivers` |
| `schoolNames` | string(2000) | ✅ | - | JSON array of school names |
| `operatingDays` | string(100) | ✅ | - | JSON array of days (e.g., `["Mon","Tue","Wed","Thu","Fri"]`) |
| `serviceAreaCenter` | point | ✅ | - | Center of service area [lng, lat] |
| `serviceAreaRadiusKm` | float | ✅ | - | Radius of service area (0.2 - 2 km, colony-level) |
| `serviceAreaPolygon` | polygon | ✅ | - | Service area boundary for spatial matching |
| `serviceAreaAddress` | string(500) | ❌ | null | Human-readable address of center |
| `extraNotes` | string(1000) | ❌ | null | Additional notes |
| `pricePerMonth` | float | ❌ | null | Monthly service price (PKR) |

**Removed Fields** (from previous version):
- ~~`serviceWindow`~~ — System generates trips for both morning & afternoon automatically
- ~~`pickupRangeKm` (enum)~~ — Replaced by `serviceAreaRadiusKm` (float) + `serviceAreaPolygon`
- ~~`isActive`~~ — Removed from UI; drivers are active if they have a valid service doc
- ~~`routeStartAddress`/`routeStartLocation`~~ — Replaced by `serviceAreaCenter`/`serviceAreaAddress`

**Indexes**:
- `driverId` (Unique)
- `serviceAreaCenter` (Key) - For geo queries
- `serviceAreaPolygon` (Key) - For spatial driver-parent matching (point-in-polygon)

---

### 📁 Collection 7: `service_requests`
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

### 📁 Collection 8: `active_services`
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

### 📁 Collection 9: `trips`
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

### 📁 Collection 10: `chat_rooms`
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

### 📁 Collection 11: `messages`
> Chat messages (Realtime enabled)

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `chatRoomId` | relationship | ✅ | - | Many-to-One → `chat_rooms` |
| `senderId` | string(36) | ✅ | - | Sender user/parent/driver ID |
| `senderRole` | enum | ✅ | - | Values: `parent`, `driver` |
| `messageType` | enum | ✅ | `text` | Values: `text`, `image`, `location` |
| `text` | string(2000) | ❌ | null | Message content |
| `imageFileId` | string(36) | ❌ | null | Storage file ID |
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

### 📁 Collection 12: `notifications`
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

### 📁 Collection 13: `reports`
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
| `attachmentFileIds` | string(500) | ❌ | null | JSON array of file IDs |
| `status` | enum | ✅ | `pending` | Values: `pending`, `investigating`, `resolved`, `dismissed` |
| `adminNotes` | string(1000) | ❌ | null | Admin response |
| `resolvedAt` | datetime | ❌ | null | Resolution timestamp |

**Indexes**:
- `reporterId` (Key)
- `reportedUserId` (Key)
- `status` (Key)
- `reportType` (Key)

---

### 📁 Collection 14: `geofence_events`
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

> **Note**: Service windows are **system-managed** — drivers don't select them. The system automatically generates trips for **both** windows based on active services.

### Daily Trip Generation Logic

```
Every day at 4:30 AM (via Appwrite Function: generate-daily-trips):

1. Get all active_services where status = 'active'
2. For each service:
   a. Get child's pickupLocation (home) and dropLocation (school)
   b. Create MORNING trip (home_to_school):
      - pickupLocation = child's home
      - dropLocation = school
      - windowStartTime = 05:00
      - windowEndTime = 09:00
   c. Create AFTERNOON trip (school_to_home):
      - pickupLocation = school
      - dropLocation = child's home
      - windowStartTime = 11:00
      - windowEndTime = 15:00
```

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

### Function 1: `generate-daily-trips`
> **Trigger**: CRON (Daily at 4:30 AM PKT)  
> **Runtime**: Node.js 18+  
> **Purpose**: Create trip records from active services based on service windows

```javascript
// Input: None (CRON triggered)
// Output: Created trip count

export default async ({ req, res, log }) => {
  const today = new Date();
  const dayOfWeek = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][today.getDay()];
  
  // Get all active services
  const activeServices = await databases.listDocuments(
    'godropme_db', 
    'active_services',
    [Query.equal('status', 'active')]
  );
  
  for (const service of activeServices.documents) {
    const driverConfig = await databases.getDocument('godropme_db', 'driver_services', service.driverId);
    const child = await databases.getDocument('godropme_db', 'children', service.childId);
    
    // Check if driver operates today
    const operatingDays = JSON.parse(driverConfig.operatingDays);
    if (!operatingDays.includes(dayOfWeek)) continue;
    
    // Create MORNING trip (Home → School)
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
    }
    
    // Create AFTERNOON trip (School → Home)
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
        windowStartTime: driverConfig.afternoonStartTime || '12:00',
        windowEndTime: driverConfig.afternoonEndTime || '15:00',
        pickupLocation: child.dropLocation,   // School
        dropLocation: child.pickupLocation,   // Home
        liveTrackingEnabled: false,
        approachingNotified: false,
        arrivedNotified: false,
        pickedNotified: false,
        droppedNotified: false
      });
    }
  }
  
  return res.json({ success: true, tripsCreated: count });
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

---

## 🔄 Appwrite Realtime Subscriptions

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

### Phase 1: Appwrite Setup & Authentication 🔐
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
- [ ] **1.6** Update `OtpController` for OTP verification
- [ ] **1.7** Create `user_service.dart` for user document CRUD
- [ ] **1.8** Add Realtime client helper to `appwrite_client.dart`
- [ ] **1.9** Handle session persistence on app restart
- [ ] **1.10** Create auth middleware for protected routes

---

### Phase 2: Parent Registration 👨‍👩‍👧
> **Priority**: HIGH | **Estimated**: 3-4 days

- [ ] **2.1** Create `parents` collection in Appwrite
- [ ] **2.2** Create `children` collection in Appwrite
- [ ] **2.3** Create storage buckets: `profile_photos`, `child_photos`
- [ ] **2.4** Create `storage_service.dart`
  - [ ] `uploadFile(bucketId, file)` → Returns file ID
  - [ ] `getFilePreview(bucketId, fileId)`
  - [ ] `deleteFile(bucketId, fileId)`
  - [ ] `compressImage(file)` → Compress before upload
- [ ] **2.5** Create `parent_service.dart`
  - [ ] `createParent(data)`
  - [ ] `getParent(userId)`
  - [ ] `updateParent(parentId, data)`
  - [ ] `uploadProfilePhoto(file)` → Returns file ID
- [ ] **2.6** Create `child_service.dart`
  - [ ] `addChild(parentId, childData)`
  - [ ] `getChildren(parentId)`
  - [ ] `updateChild(childId, data)`
  - [ ] `deleteChild(childId)`
- [ ] **2.7** Update `ParentNameScreen` controller
- [ ] **2.8** Update `AddChildrenScreen` controller
- [ ] **2.9** Sync local drafts with Appwrite on submit

---

### Phase 3: Driver Registration 🚗
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

- [ ] **4.1** Create `service_requests` collection
- [ ] **4.2** Create `active_services` collection
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

- [ ] **5.1** Create `trips` collection
- [ ] **5.2** Create `geofence_events` collection
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

- [ ] **6.1** Create `chat_rooms` collection
- [ ] **6.2** Create `messages` collection
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

- [ ] **7.1** Create `notifications` collection
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

- [ ] **8.1** Create `ratings` collection
- [ ] **8.2** Create `reports` collection
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
│   ├── auth_service.dart          🔴 Create
│   ├── database_constants.dart    🔴 Create
│   ├── storage_service.dart       🔴 Create
│   ├── realtime_service.dart      🔴 Create
│   └── functions_service.dart     🔴 Create
├── user_service.dart              🔴 Create
├── parent_service.dart            🔴 Create
├── child_service.dart             🔴 Create
├── driver_service.dart            🔴 Create
├── vehicle_service.dart           🔴 Create
├── driver_config_service.dart     🔴 Create
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
| `generate-daily-trips` | CRON | Node.js 18 | `0 4 30 * * *` (4:30 AM daily) |
| `process-geofence` | Event | Node.js 18 | `databases.godropme_db.collections.trips.documents.*.update` |
| `notify-trip-status` | Event | Node.js 18 | `databases.godropme_db.collections.trips.documents.*.update` |
| `calculate-driver-rating` | Event | Node.js 18 | `databases.godropme_db.collections.ratings.documents.*.create` |
| `match-drivers` | HTTP | Node.js 18 | `POST /v1/functions/{functionId}/executions` |
| `send-push-notification` | HTTP | Node.js 18 | `POST /v1/functions/{functionId}/executions` |
| `cleanup-old-data` | CRON | Node.js 18 | `0 2 0 * * 0` (Sunday 2:00 AM) |

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
4. Create all 15 collections with attributes (see schema above)
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

> **Last Updated**: November 27, 2025  
> **Author**: Development Team
