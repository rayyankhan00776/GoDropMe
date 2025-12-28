# match-drivers Function

Appwrite server function for matching available drivers based on child's location, school, and gender preferences.

## Overview

This function handles driver matching logic server-side for better performance, security, and maintainability. It replaces client-side geo-queries with a single optimized function call.

## Function Details

- **Name**: `match-drivers`
- **Runtime**: Node.js 18+
- **Trigger**: Manual execution from client
- **Timeout**: 15 seconds (default)

## Request Body

```json
{
  "childId": "child_123",           // Child document ID (optional, for logging)
  "pickupPoint": [71.5249, 34.0151], // [longitude, latitude]
  "schoolId": "school_456",          // School document ID
  "gender": "Male"                   // "Male" or "Female"
}
```

## Response Format

### Success Response

```json
{
  "success": true,
  "drivers": [
    {
      "driverId": "driver_789",
      "name": "John Doe",
      "profilePhotoUrl": "https://cloud.appwrite.io/...",
      "rating": 4.8,
      "totalTrips": 150,
      "phone": "+923001234567",
      "vehicle": {
        "type": "car",
        "brand": "Toyota",
        "model": "Corolla",
        "color": "White",
        "seatCapacity": 4,
        "numberPlate": "ABC-1234"
      },
      "serviceCategory": "Both",
      "monthlyPricePkr": 5000,
      "serviceAreaAddress": "Hayatabad, Peshawar",
      "extraNotes": "Experienced driver with 5+ years",
      "serviceId": "service_config_123"
    }
  ],
  "count": 1,
  "message": "Found 1 available drivers."
}
```

### Error Response

```json
{
  "success": false,
  "message": "Invalid or missing pickupPoint. Expected [lng, lat] array."
}
```

## Matching Logic

The function performs the following steps:

1. **Validate Input**: Checks required fields (pickupPoint, schoolId, gender)
2. **Geo-Query**: `Query.contains('serviceAreaPolygon', pickupPoint)` - Finds driver service areas containing the pickup location
3. **School Filter**: `Query.contains('schoolIds', [schoolId])` - Filters drivers serving the specified school
4. **Gender Filter**: Matches service category with child's gender or "Both"
5. **Status Check**: Only includes active drivers (`users.status = 'active'`)
6. **Fetch Details**: Retrieves driver profile and vehicle information
7. **Format Response**: Returns standardized driver listing data

## Deployment

### Via Appwrite Console

1. Go to Functions → Create Function
2. Name: `match-drivers`
3. Runtime: Node.js 18+
4. Upload: `functions/match-drivers/` directory
5. Set execute permissions for authenticated users

### Via Appwrite CLI

```bash
appwrite deploy function
```

## Testing

### Test Request (using Appwrite Console)

```json
{
  "childId": "test_child",
  "pickupPoint": [71.5249, 34.0151],
  "schoolId": "675129e7002f54e49f0c",
  "gender": "Male"
}
```

## Integration

### Flutter Client

```dart
import 'dart:convert';
import 'package:godropme/services/appwrite/appwrite_client.dart';

Future<List<DriverListing>> matchDrivers({
  required List<double> pickupPoint,
  required String schoolId,
  required String gender,
}) async {
  final functions = AppwriteClient.functionsService();
  
  final execution = await functions.createExecution(
    functionId: 'match-drivers',
    body: jsonEncode({
      'pickupPoint': pickupPoint,
      'schoolId': schoolId,
      'gender': gender,
    }),
    xasync: false,
  );
  
  final response = jsonDecode(execution.responseBody);
  
  if (response['success'] != true) {
    throw Exception(response['message']);
  }
  
  return (response['drivers'] as List)
      .map((d) => DriverListing.fromJson(d))
      .toList();
}
```

