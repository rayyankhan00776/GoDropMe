import 'package:appwrite/appwrite.dart';
import 'package:godropme/config/environment.dart';

/// Appwrite client singleton used across the app.
///
/// Uses configuration from `Environment` to centralize values.
class AppwriteClient {
  AppwriteClient._();

  static final AppwriteClient instance = AppwriteClient._();

  static final Client client = Client()
    ..setEndpoint(Environment.appwritePublicEndpoint)
    ..setProject(Environment.appwriteProjectId);

  /// Convenience helper to build the Account service.
  static Account accountService() => Account(client);

  /// Convenience helper to build the Databases service.
  static Databases databasesService() => Databases(client);

  /// Convenience helper to build the Storage service.
  static Storage storageService() => Storage(client);
}
