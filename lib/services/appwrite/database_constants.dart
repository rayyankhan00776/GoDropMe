/// Appwrite Database Constants for GoDropMe
/// 
/// Contains all collection IDs, bucket IDs, and database configuration.
/// Reference: docs/TODO.md for full schema documentation.
library;

/// Appwrite Cloud Configuration
class AppwriteConfig {
  AppwriteConfig._();
  
  /// Appwrite Cloud endpoint
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  
  /// GoDropMe Project ID
  static const String projectId = '68ed397e000f277c6936';
  
  /// Main database ID
  static const String databaseId = 'godropme_db';
}

/// Collection IDs for all database collections
class Collections {
  Collections._();
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CORE COLLECTIONS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Core user authentication and role management
  static const String users = 'users';
  
  /// Parent profile and details
  static const String parents = 'parents';
  
  /// Children registered by parents
  static const String children = 'children';
  
  /// Driver profile and verification
  static const String drivers = 'drivers';
  
  /// Driver vehicle information
  static const String vehicles = 'vehicles';
  
  /// Driver service configuration (schools, area, capacity)
  static const String driverServices = 'driver_services';
  
  /// Schools master data (name, location, city)
  static const String schools = 'schools';
  
  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Service requests from parents to drivers
  static const String serviceRequests = 'service_requests';
  
  /// Active/ongoing service subscriptions
  static const String activeServices = 'active_services';
  
  /// Individual trip records
  static const String trips = 'trips';
  
  // ═══════════════════════════════════════════════════════════════════════════
  // COMMUNICATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Chat rooms between parents and drivers
  static const String chatRooms = 'chat_rooms';
  
  /// Chat messages within rooms
  static const String messages = 'messages';
  
  /// Push notifications for users
  static const String notifications = 'notifications';
  
  // ═══════════════════════════════════════════════════════════════════════════
  // SAFETY & MONITORING
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Safety reports filed by parents
  static const String reports = 'reports';
  
  /// Geofence entry/exit events
  static const String geofenceEvents = 'geofence_events';
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ANALYTICS & HISTORY
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Daily aggregated analytics
  static const String dailyAnalytics = 'daily_analytics';
  
  /// Archived trip history records
  static const String tripHistory = 'trip_history';
  
  /// Driver ratings from parents
  static const String ratings = 'ratings';
}

/// Storage Bucket IDs
class Buckets {
  Buckets._();
  
  /// Parent & driver profile photos
  /// Max: 5MB | Types: jpg, jpeg, png, webp
  static const String profilePhotos = 'profile_photos';
  
  /// CNIC, License, Registration documents
  /// Max: 10MB | Types: jpg, jpeg, png, pdf
  static const String documents = 'documents';
  
  /// Vehicle photos
  /// Max: 10MB | Types: jpg, jpeg, png, webp
  static const String vehiclePhotos = 'vehicle_photos';
  
  /// Children's photos
  /// Max: 5MB | Types: jpg, jpeg, png, webp
  static const String childPhotos = 'child_photos';
  
  /// Chat image attachments
  /// Max: 5MB | Types: jpg, jpeg, png, webp
  static const String chatAttachments = 'chat_attachments';
  
  /// Report evidence files
  /// Max: 10MB | Types: jpg, jpeg, png, pdf
  static const String reportAttachments = 'report_attachments';
  
  /// Generate full URL for a file in a bucket
  static String getFileUrl(String bucketId, String fileId) {
    return '${AppwriteConfig.endpoint}/storage/buckets/$bucketId/files/$fileId/view?project=${AppwriteConfig.projectId}';
  }
  
  /// Generate preview URL for an image file
  static String getPreviewUrl(String bucketId, String fileId, {int? width, int? height}) {
    var url = '${AppwriteConfig.endpoint}/storage/buckets/$bucketId/files/$fileId/preview?project=${AppwriteConfig.projectId}';
    if (width != null) url += '&width=$width';
    if (height != null) url += '&height=$height';
    return url;
  }
}

/// Messaging Topic IDs
class Topics {
  Topics._();
  
  /// Broadcast to all parents
  static const String allParents = 'all_parents';
  
  /// Broadcast to all drivers
  static const String allDrivers = 'all_drivers';
  
  /// Trip status updates
  static const String tripNotifications = 'trip_notifications';
  
  /// Service request alerts
  static const String serviceRequests = 'service_requests';
  
  /// System-wide announcements
  static const String systemAnnouncements = 'system_announcements';
  
  /// Geofence entry/exit alerts
  static const String geofenceAlerts = 'geofence_alerts';
}

/// Enum values used in collections
class CollectionEnums {
  CollectionEnums._();
  
  // User Roles
  static const String roleParent = 'parent';
  static const String roleDriver = 'driver';
  static const String roleAdmin = 'admin';
  
  // User Status (from users table - unified for all user types)
  // Values: pending, active, suspended, rejected
  static const String statusPending = 'pending';
  static const String statusActive = 'active';
  static const String statusSuspended = 'suspended';
  static const String statusRejected = 'rejected';
  
  // Gender
  static const String genderMale = 'Male';
  static const String genderFemale = 'Female';
  
  // Vehicle Types
  static const String vehicleCar = 'car';
  static const String vehicleRickshaw = 'rickshaw';
  
  // Service Request Status
  static const String requestPending = 'pending';
  static const String requestAccepted = 'accepted';
  static const String requestRejected = 'rejected';
  static const String requestExpired = 'expired';
  static const String requestCancelled = 'cancelled';
  
  // Active Service Status
  static const String serviceActive = 'active';
  static const String servicePaused = 'paused';
  static const String serviceTerminated = 'terminated';
  
  // Trip Status
  static const String tripScheduled = 'scheduled';
  static const String tripEnroute = 'enroute';
  static const String tripArrived = 'arrived';
  static const String tripPicked = 'picked';
  static const String tripInTransit = 'in_transit';
  static const String tripDropped = 'dropped';
  static const String tripCompleted = 'completed';
  static const String tripAbsent = 'absent';
  static const String tripCancelled = 'cancelled';
  static const String tripNoShow = 'no_show';
  
  // Trip Type
  static const String tripTypeMorning = 'morning';
  static const String tripTypeAfternoon = 'afternoon';
  
  // Trip Direction
  static const String directionHomeToSchool = 'home_to_school';
  static const String directionSchoolToHome = 'school_to_home';
  
  // Message Type
  static const String messageText = 'text';
  static const String messageImage = 'image';
  static const String messageLocation = 'location';
  
  // Notification Type
  static const String notifyTripUpdate = 'trip_update';
  static const String notifyServiceRequest = 'service_request';
  static const String notifyChat = 'chat';
  static const String notifyGeofence = 'geofence';
  static const String notifySystem = 'system';
  
  // Report Type
  static const String reportSafety = 'safety';
  static const String reportBehavior = 'behavior';
  static const String reportDelay = 'delay';
  static const String reportOther = 'other';
  
  // Report Status
  static const String reportOpen = 'open';
  static const String reportInvestigating = 'investigating';
  static const String reportResolved = 'resolved';
  static const String reportDismissed = 'dismissed';
  
  // Geofence Event Type
  static const String geofenceEntry = 'entry';
  static const String geofenceExit = 'exit';
  
  // Geofence Location Type
  static const String locationHome = 'home';
  static const String locationSchool = 'school';
}
