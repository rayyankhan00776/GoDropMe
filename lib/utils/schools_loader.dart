import 'package:appwrite/appwrite.dart';
import 'package:godropme/models/school.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Centralized loader for schools data from Appwrite.
/// 
/// This is the single source of truth for all school data in the app.
/// Both parent-side and driver-side features should use this loader
/// to get the list of schools.
/// 
/// Data source: Appwrite `schools` table (no local fallback - ensures fresh data)
class SchoolsLoader {
  static List<School>? _cachedSchools;
  static Map<String, School>? _schoolsById;
  static Map<String, School>? _schoolsByName;
  static DateTime? _lastFetchTime;
  static const _cacheValidityDuration = Duration(hours: 1);

  /// Load all active schools from Appwrite (with caching)
  static Future<List<School>> load({bool forceRefresh = false}) async {
    // Return cached if available and not expired
    if (!forceRefresh && _cachedSchools != null && _isCacheValid()) {
      return _cachedSchools!;
    }

    try {
      final schools = await _fetchFromAppwrite();
      _updateCache(schools);
      return schools;
    } catch (e) {
      // Log error in debug mode
      assert(() {
        // ignore: avoid_print
        print('SchoolsLoader error: $e');
        return true;
      }());
      
      // Return cached data if available (even if expired)
      if (_cachedSchools != null) {
        return _cachedSchools!;
      }
      
      // No cache available, return empty
      return [];
    }
  }

  /// Check if cache is still valid
  static bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration;
  }

  /// Update all caches
  static void _updateCache(List<School> schools) {
    _cachedSchools = schools;
    _schoolsById = {for (final s in schools) s.id: s};
    _schoolsByName = {for (final s in schools) s.name: s};
    _lastFetchTime = DateTime.now();
  }

  /// Fetch schools from Appwrite database
  static Future<List<School>> _fetchFromAppwrite() async {
    final tablesDB = AppwriteClient.tablesDBService();
    
    // Query only active schools, ordered by name
    final result = await tablesDB.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: Collections.schools,
      queries: [
        Query.equal('isActive', true),
        Query.orderAsc('name'),
        Query.limit(100), // More than enough for schools
      ],
    );

    return result.rows.map((row) {
      final data = Map<String, dynamic>.from(row.data);
      data['\$id'] = row.$id; // Ensure ID is included
      return School.fromJson(data);
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ID-BASED LOOKUPS (Primary - use these for database references)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get school by ID (primary lookup method)
  /// Use this when you have a schoolId from database
  static Future<School?> getById(String id) async {
    // Check cache first
    if (_schoolsById != null && _isCacheValid()) {
      return _schoolsById![id];
    }
    
    // Load schools if not cached
    await load();
    return _schoolsById?[id];
  }

  /// Get multiple schools by their IDs
  /// Use this for driver_services.schoolIds
  static Future<List<School>> getByIds(List<String> ids) async {
    await load(); // Ensure cache is populated
    
    final schools = <School>[];
    for (final id in ids) {
      final school = _schoolsById?[id];
      if (school != null) {
        schools.add(school);
      }
    }
    return schools;
  }

  /// Get school IDs for a list of schools
  static List<String> getIds(List<School> schools) {
    return schools.map((s) => s.id).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NAME-BASED LOOKUPS (For UI display and form selection)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get school by name (for backward compatibility and form lookups)
  static Future<School?> getByName(String name) async {
    // Check cache first
    if (_schoolsByName != null && _isCacheValid()) {
      return _schoolsByName![name];
    }
    
    // Load schools if not cached
    await load();
    return _schoolsByName?[name];
  }

  /// Get school names only (for dropdowns)
  static Future<List<String>> getSchoolNames() async {
    final schools = await load();
    return schools.map((s) => s.name).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATION HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get school location by ID
  /// Returns [lng, lat] or null if not found
  static Future<List<double>?> getLocationById(String id) async {
    final school = await getById(id);
    return school?.locationPoint;
  }

  /// Get multiple school locations by IDs
  /// Returns map of id -> [lng, lat]
  static Future<Map<String, List<double>>> getLocationsByIds(List<String> ids) async {
    final schools = await getByIds(ids);
    return {for (final s in schools) s.id: s.locationPoint};
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Clear cache (useful for hot reload during development or after admin updates)
  static void clearCache() {
    _cachedSchools = null;
    _schoolsById = null;
    _schoolsByName = null;
    _lastFetchTime = null;
  }

  /// Check if schools are loaded
  static bool get isLoaded => _cachedSchools != null && _cachedSchools!.isNotEmpty;
}
