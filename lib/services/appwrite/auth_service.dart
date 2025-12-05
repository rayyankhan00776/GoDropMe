import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Appwrite Authentication Service for GoDropMe
/// 
/// Handles Email OTP authentication flow:
/// 1. User enters email
/// 2. OTP sent to email
/// 3. User enters OTP to verify
/// 4. Check if user exists in database
/// 5. Route to registration or dashboard based on role
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  /// Use shared AppwriteClient instances
  final Account _account = AppwriteClient.accountService();
  final Databases _databases = AppwriteClient.databasesService();
  final TablesDB _tablesDB = AppwriteClient.tablesDBService();
  
  /// Currently logged in user
  models.User? _currentUser;
  models.User? get currentUser => _currentUser;
  
  /// Current session
  models.Session? _currentSession;
  models.Session? get currentSession => _currentSession;
  
  /// User ID for OTP flow (stored between createEmailToken and createSession)
  String? _pendingUserId;
  
  AuthService._();
  
  /// Get the Appwrite client for other services
  Client get client => AppwriteClient.client;
  
  /// Get Account instance
  Account get account => _account;
  
  /// Get Databases instance
  Databases get databases => _databases;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL OTP AUTHENTICATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Step 1: Send OTP to email
  /// 
  /// Creates an email token and sends OTP to the provided email.
  /// Returns the user ID needed for step 2.
  /// 
  /// ```dart
  /// final result = await AuthService.instance.sendEmailOTP('user@email.com');
  /// if (result.success) {
  ///   // Navigate to OTP verification screen
  ///   // result.userId is stored internally
  /// }
  /// ```
  Future<AuthResult> sendEmailOTP(String email) async {
    try {
      final token = await _account.createEmailToken(
        userId: ID.unique(),
        email: email,
      );
      
      _pendingUserId = token.userId;
      
      debugPrint('📧 OTP sent to: $email (userId: ${token.userId})');
      
      return AuthResult.success(
        message: 'OTP sent to $email',
        userId: token.userId,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Send OTP Error: ${e.message}');
      return AuthResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Send OTP Error: $e');
      return AuthResult.failure('Failed to send OTP. Please try again.');
    }
  }
  
  /// Step 2: Verify OTP and create session
  /// 
  /// Verifies the OTP entered by user and creates a session.
  /// After successful verification, checks if user exists in database.
  /// 
  /// ```dart
  /// final result = await AuthService.instance.verifyEmailOTP('123456');
  /// if (result.success) {
  ///   if (result.isNewUser) {
  ///     // Navigate to role selection / registration
  ///   } else {
  ///     // Navigate to dashboard based on result.userRole
  ///   }
  /// }
  /// ```
  Future<AuthResult> verifyEmailOTP(String otp) async {
    if (_pendingUserId == null) {
      return AuthResult.failure('Please request OTP first');
    }
    
    try {
      // Create session with OTP
      final session = await _account.createSession(
        userId: _pendingUserId!,
        secret: otp,
      );
      
      _currentSession = session;
      
      // Get user details
      _currentUser = await _account.get();
      
      debugPrint('✅ OTP Verified! User: ${_currentUser!.email}');
      
      // Check if user exists in database
      final userCheck = await _checkUserInDatabase(_currentUser!.$id);
      
      // Clear pending user ID
      _pendingUserId = null;
      
      return AuthResult.success(
        message: 'Login successful',
        userId: _currentUser!.$id,
        email: _currentUser!.email,
        isNewUser: userCheck.isNewUser,
        userRole: userCheck.role,
        status: userCheck.status,
        statusReason: userCheck.statusReason,
        hasDriverProfile: userCheck.hasDriverProfile,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Verify OTP Error: ${e.message}');
      return AuthResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Verify OTP Error: $e');
      return AuthResult.failure('Verification failed. Please try again.');
    }
  }
  
  /// Check if user exists in users collection and get their role
  /// 
  /// Uses the Auth user ID as the row ID for direct lookup (more efficient)
  /// Status is read from users table (unified for all user types)
  Future<_UserCheckResult> _checkUserInDatabase(String authUserId) async {
    try {
      // Get user row directly using authUserId as row ID
      final userRow = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.users,
        rowId: authUserId,
      );
      
      final role = userRow.data['role'] as String?;
      // Read status from users table (unified status: pending, active, suspended, rejected)
      final status = userRow.data['status'] as String?;
      // Single reason field for both suspension and rejection
      final statusReason = userRow.data['statusReason'] as String?;
      bool hasDriverProfile = false;
      
      // If driver, check if profile exists in drivers table
      if (role == CollectionEnums.roleDriver) {
        final driverResponse = await _tablesDB.listRows(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.drivers,
          queries: [
            Query.equal('userId', userRow.$id),
            Query.limit(1),
          ],
        );
        
        if (driverResponse.rows.isNotEmpty) {
          hasDriverProfile = true;
        } else {
          // Driver user exists but hasn't completed registration
          debugPrint('👤 Driver user found but no driver profile - incomplete registration');
        }
      }
      
      debugPrint('👤 Existing user - Role: $role, Status: $status, hasProfile: $hasDriverProfile');
      
      return _UserCheckResult(
        isNewUser: false,
        role: role,
        status: status,
        statusReason: statusReason,
        hasDriverProfile: hasDriverProfile,
      );
    } on AppwriteException catch (e) {
      // 404 means user doesn't exist in database (new user)
      if (e.code == 404) {
        debugPrint('👤 New user - no record in database');
        return _UserCheckResult(isNewUser: true);
      }
      debugPrint('⚠️ Error checking user in database: $e');
      // Assume new user if we can't check
      return _UserCheckResult(isNewUser: true);
    } catch (e) {
      debugPrint('⚠️ Error checking user in database: $e');
      // Assume new user if we can't check
      return _UserCheckResult(isNewUser: true);
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Check if user is currently logged in
  /// 
  /// Call this on app startup to restore session.
  /// ```dart
  /// final result = await AuthService.instance.checkSession();
  /// if (result.success) {
  ///   // User is logged in, navigate based on role
  /// } else {
  ///   // Navigate to login screen
  /// }
  /// ```
  Future<AuthResult> checkSession() async {
    try {
      _currentUser = await _account.get();
      _currentSession = await _account.getSession(sessionId: 'current');
      
      debugPrint('✅ Session restored for: ${_currentUser!.email}');
      
      // Check user role in database
      final userCheck = await _checkUserInDatabase(_currentUser!.$id);
      
      return AuthResult.success(
        message: 'Session active',
        userId: _currentUser!.$id,
        email: _currentUser!.email,
        isNewUser: userCheck.isNewUser,
        userRole: userCheck.role,
        status: userCheck.status,
        statusReason: userCheck.statusReason,
        hasDriverProfile: userCheck.hasDriverProfile,
      );
    } on AppwriteException catch (e) {
      debugPrint('ℹ️ No active session: ${e.message}');
      _currentUser = null;
      _currentSession = null;
      return AuthResult.failure('No active session');
    } catch (e) {
      debugPrint('❌ Check session error: $e');
      return AuthResult.failure('Session check failed');
    }
  }
  
  /// Logout current user
  /// 
  /// Deletes the current session and clears local state.
  Future<AuthResult> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      
      _currentUser = null;
      _currentSession = null;
      _pendingUserId = null;
      
      debugPrint('✅ Logged out successfully');
      
      return AuthResult.success(message: 'Logged out');
    } on AppwriteException catch (e) {
      debugPrint('❌ Logout error: ${e.message}');
      // Clear local state anyway
      _currentUser = null;
      _currentSession = null;
      return AuthResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      _currentUser = null;
      _currentSession = null;
      return AuthResult.failure('Logout failed');
    }
  }
  
  /// Logout from all devices
  Future<AuthResult> logoutAll() async {
    try {
      await _account.deleteSessions();
      
      _currentUser = null;
      _currentSession = null;
      _pendingUserId = null;
      
      debugPrint('✅ Logged out from all devices');
      
      return AuthResult.success(message: 'Logged out from all devices');
    } on AppwriteException catch (e) {
      debugPrint('❌ Logout all error: ${e.message}');
      return AuthResult.failure(_parseAppwriteError(e));
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // USER REGISTRATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Register a new user with their selected role
  /// 
  /// Creates entries in users collection and role-specific collection.
  /// Call after OTP verification for new users.
  /// 
  /// Uses the Auth user ID as the document ID for easy lookup.
  /// 
  /// ```dart
  /// final result = await AuthService.instance.registerUser(
  ///   role: 'parent',
  ///   fullName: 'John Doe',
  ///   email: 'john@email.com',
  /// );
  /// ```
  Future<AuthResult> registerUser({
    required String role,
    required String fullName,
    required String email,
  }) async {
    if (_currentUser == null) {
      return AuthResult.failure('Please login first');
    }
    
    try {
      // Use Auth user ID as row ID for users table
      // This makes lookup efficient (getRow vs query)
      final authUserId = _currentUser!.$id;
      
      // Create user row in users table
      // Row ID = Auth user ID (for easy lookup)
      final userRow = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.users,
        rowId: authUserId, // Use auth ID as row ID
        data: {
          'email': email,
          'role': role,
          'isProfileComplete': role == CollectionEnums.roleParent ? true : false,
          'status': role == CollectionEnums.roleParent
              ? CollectionEnums.statusActive
              : CollectionEnums.statusPending,
        },
        permissions: [
          Permission.read(Role.user(authUserId)),
          Permission.update(Role.user(authUserId)),
          Permission.delete(Role.user(authUserId)),
        ],
      );
      
      debugPrint('✅ User row created: ${userRow.$id}');
      
      // Create role-specific row
      // For parents: create parent profile immediately
      // For drivers: only create users row now, driver profile created later with all documents
      if (role == CollectionEnums.roleParent) {
        final parentRow = await _tablesDB.createRow(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.parents,
          rowId: ID.unique(),
          data: {
            'userId': userRow.$id,
            'fullName': fullName,
            'email': email,
            'phone': '', // Phone is stored in parents table only
          },
          permissions: [
            Permission.read(Role.user(authUserId)),
            Permission.update(Role.user(authUserId)),
            Permission.delete(Role.user(authUserId)),
          ],
        );
        debugPrint('✅ Parent profile created: ${parentRow.$id}');
      }
      // NOTE: Driver profile (drivers table) is NOT created here.
      // It will be created at the end of driver registration when all
      // required documents (CNIC, license, photos) are collected.
      // See: DriverRegistrationService.submitRegistration()
      
      return AuthResult.success(
        message: 'Registration successful',
        userId: userRow.$id,
        userRole: role,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Registration error: ${e.message}');
      return AuthResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      return AuthResult.failure('Registration failed. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Parse Appwrite exceptions into user-friendly messages
  String _parseAppwriteError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Invalid OTP. Please try again.';
      case 404:
        return 'User not found.';
      case 409:
        return 'User already exists.';
      case 429:
        return 'Too many attempts. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
  
  /// Check if email is valid
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Check if OTP is valid format (6 digits)
  static bool isValidOTP(String otp) {
    return RegExp(r'^\d{6}$').hasMatch(otp);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result of an authentication operation
class AuthResult {
  final bool success;
  final String message;
  final String? userId;
  final String? email;
  final bool? isNewUser;
  final String? userRole;
  /// User status from users table (pending, active, suspended, rejected)
  final String? status;
  /// Reason for suspension or rejection (used when status is suspended/rejected)
  final String? statusReason;
  final bool hasDriverProfile; // True if driver has completed registration
  
  const AuthResult._({
    required this.success,
    required this.message,
    this.userId,
    this.email,
    this.isNewUser,
    this.userRole,
    this.status,
    this.statusReason,
    this.hasDriverProfile = false,
  });
  
  factory AuthResult.success({
    required String message,
    String? userId,
    String? email,
    bool? isNewUser,
    String? userRole,
    String? status,
    String? statusReason,
    bool hasDriverProfile = false,
  }) {
    return AuthResult._(
      success: true,
      message: message,
      userId: userId,
      email: email,
      isNewUser: isNewUser,
      userRole: userRole,
      status: status,
      statusReason: statusReason,
      hasDriverProfile: hasDriverProfile,
    );
  }
  
  factory AuthResult.failure(String message) {
    return AuthResult._(
      success: false,
      message: message,
    );
  }
  
  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message, userId: $userId, '
           'email: $email, isNewUser: $isNewUser, userRole: $userRole, '
           'status: $status, hasDriverProfile: $hasDriverProfile)';
  }
}

/// Internal class for user database check
class _UserCheckResult {
  final bool isNewUser;
  final String? role;
  /// User status from users table (pending, active, suspended, rejected)
  final String? status;
  /// Reason for suspension or rejection
  final String? statusReason;
  final bool hasDriverProfile; // True if driver has completed registration
  
  const _UserCheckResult({
    required this.isNewUser,
    this.role,
    this.status,
    this.statusReason,
    this.hasDriverProfile = false,
  });
}