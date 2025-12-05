import 'package:appwrite/appwrite.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Appwrite client singleton used across the app.
///
/// Uses configuration from `AppwriteConfig` to centralize values.
class AppwriteClient {
  AppwriteClient._();

  static final AppwriteClient instance = AppwriteClient._();

  static final Client client = Client()
    ..setEndpoint(AppwriteConfig.endpoint)
    ..setProject(AppwriteConfig.projectId);

  /// Convenience helper to build the Account service.
  static Account accountService() => Account(client);

  /// Convenience helper to build the Databases service.
  /// @deprecated Use tablesDBService() instead - Databases API is deprecated since v1.8.0
  static Databases databasesService() => Databases(client);
  
  /// Convenience helper to build the TablesDB service.
  /// This is the new API replacing Databases (since v1.8.0)
  static TablesDB tablesDBService() => TablesDB(client);

  /// Convenience helper to build the Storage service.
  static Storage storageService() => Storage(client);

  /// Convenience helper to build the Functions service.
  static Functions functionsService() => Functions(client);

  /// Convenience helper to build the Messaging service.
  static Messaging messagingService() => Messaging(client);

  /// Convenience helper to build the Realtime service.
  static Realtime realtimeService() => Realtime(client);
}
