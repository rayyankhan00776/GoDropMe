import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/parentSide/addChildren/models/child.dart';
import 'package:godropme/services/appwrite/child_service.dart';
import 'package:godropme/services/appwrite/parent_service.dart';
import 'package:godropme/services/appwrite/trip_service.dart';
import 'package:godropme/services/appwrite/active_service_service.dart';
import 'package:godropme/utils/schools_loader.dart';

/// States for the absent button based on trip status
enum AbsentButtonState {
  loading,        // Still loading trip data
  noService,      // Child has no active service / no childId
  noTrips,        // No trips scheduled for today
  canMarkAbsent,  // Has trips that can be marked absent (scheduled, driver_enroute, arrived)
  alreadyAbsent,  // Already marked absent today
  tripInProgress, // Trip is in progress (picked, in_transit) - too late to mark absent
  tripsCompleted, // All trips completed (dropped) or cancelled
}

class AddChildrenController extends GetxController {
  final RxList<Map<String, dynamic>> children = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSyncing = false.obs;
  final errorMessage = ''.obs;
  
  /// Parent ID from Appwrite (set when loading from backend)
  String? _parentId;
  String? get parentId => _parentId;

  @override
  void onInit() {
    super.onInit();
    loadChildren();
  }

  /// Load children from Appwrite backend, fallback to local storage
  Future<void> loadChildren() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // Try to load from Appwrite first
      final result = await ChildService.instance.getChildren();
      
      if (result.success && result.children.isNotEmpty) {
        // Get parent ID from first child
        _parentId = result.children.first.parentId;
        
        // Convert to Map format for UI
        final childMaps = result.children.map((c) => c.toJson()).toList();
        
        // Pre-populate school names so UI doesn't have to wait
        await _populateSchoolNames(childMaps);
        
        children.assignAll(childMaps);
        
        // Sync to local storage for offline access
        await LocalStorage.replaceJsonList(StorageKeys.childrenList, childMaps);
        
        debugPrint('✅ Loaded ${result.children.length} children from Appwrite');
        
        // Load trip states for absent button (async, don't block UI)
        loadChildTripStates();
        return;
      }
      
      // Fallback: Load from local storage (offline or new user)
      final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
      for (final m in list) {
        m.remove('disabled');
      }
      
      // Pre-populate school names for local data too
      await _populateSchoolNames(list);
      
      children.assignAll(list);
      debugPrint('📱 Loaded ${list.length} children from local storage');
      
      // Load trip states for local data too
      loadChildTripStates();
      
    } catch (e) {
      debugPrint('❌ Error loading children: $e');
      // Fallback to local storage on error
      final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
      children.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Pre-populate school names from schoolId for UI display
  /// This runs in the controller so data is ready before rendering
  Future<void> _populateSchoolNames(List<Map<String, dynamic>> childMaps) async {
    // Collect all unique school IDs
    final idsToLookup = <String>{};
    for (final child in childMaps) {
      final schoolId = child['schoolId']?.toString();
      if (schoolId != null && schoolId.isNotEmpty) {
        idsToLookup.add(schoolId);
      }
    }
    
    if (idsToLookup.isEmpty) return;
    
    try {
      // Lookup all schools at once (efficient batch query)
      final schools = await SchoolsLoader.getByIds(idsToLookup.toList());
      final idToName = {for (final s in schools) s.id: s.name};
      
      // Add schoolName to each child map for UI display
      for (final child in childMaps) {
        final schoolId = child['schoolId']?.toString();
        if (schoolId != null && idToName.containsKey(schoolId)) {
          child['_schoolName'] = idToName[schoolId]; // Use underscore prefix for display-only field
        }
      }
      debugPrint('📍 Pre-loaded ${idsToLookup.length} school names');
    } catch (e) {
      debugPrint('⚠️ Failed to pre-load school names: $e');
      // Continue without - UI will show fallback
    }
  }

  /// Add a child to local storage (draft mode)
  /// Use [syncChildToBackend] to persist to Appwrite
  Future<void> addChild(Map<String, dynamic> data) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    list.add(data);
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
    debugPrint('📝 Child added to local draft');
  }

  /// Add child and sync to Appwrite backend
  Future<bool> addChildWithSync(Map<String, dynamic> data, {File? photo}) async {
    isSyncing.value = true;
    errorMessage.value = '';
    
    try {
      // Ensure we have parent ID
      if (_parentId == null) {
        final parentResult = await ParentService.instance.getParent();
        if (!parentResult.success || parentResult.parent?.id == null) {
          errorMessage.value = 'Parent profile not found. Please complete registration.';
          return false;
        }
        _parentId = parentResult.parent!.id;
      }
      
      final child = ChildModel.fromJson(data);
      final result = await ChildService.instance.addChild(
        parentId: _parentId!,
        child: child,
        photo: photo,
      );
      
      if (!result.success) {
        errorMessage.value = result.message;
        return false;
      }
      
      // Refresh the list from backend
      await loadChildren();
      debugPrint('✅ Child synced to Appwrite: ${result.child?.id}');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error syncing child: $e');
      errorMessage.value = 'Failed to save child. Please try again.';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> updateChild(int index, Map<String, dynamic> data) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    if (index < 0 || index >= list.length) return;
    list[index] = data;
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
  }

  /// Update child and sync to Appwrite
  Future<bool> updateChildWithSync(int index, Map<String, dynamic> data, {File? photo}) async {
    if (index < 0 || index >= children.length) return false;
    
    final existing = children[index];
    final childId = existing['id']?.toString() ?? existing['\$id']?.toString();
    
    if (childId == null || childId.isEmpty) {
      // No backend ID - this is a local draft, add it instead
      return addChildWithSync(data, photo: photo);
    }
    
    isSyncing.value = true;
    errorMessage.value = '';
    
    try {
      final child = ChildModel.fromJson(data);
      final result = await ChildService.instance.updateChild(
        childId: childId,
        name: child.name,
        age: child.age,
        gender: child.gender,
        schoolId: child.schoolId,
        pickPoint: child.pickPoint,
        dropPoint: child.dropPoint,
        relationshipToChild: child.relationshipToChild,
        schoolOpenTime: child.schoolOpenTime,
        schoolOffTime: child.schoolOffTime,
        pickLocation: child.pickLocation,
        dropLocation: child.dropLocation,
        specialNotes: child.specialNotes,
      );
      
      if (!result.success) {
        errorMessage.value = result.message;
        return false;
      }
      
      // Update photo if provided
      if (photo != null) {
        await ChildService.instance.updateChildPhoto(
          childId: childId,
          photo: photo,
          oldPhotoUrl: existing['photoUrl']?.toString(),
        );
      }
      
      await loadChildren();
      debugPrint('✅ Child updated in Appwrite: $childId');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error updating child: $e');
      errorMessage.value = 'Failed to update child. Please try again.';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  /// Delete a child entry at [index] from local storage and Appwrite
  Future<void> deleteChild(int index) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    if (index < 0 || index >= list.length) return;
    
    final child = list[index];
    final childId = child['id']?.toString() ?? child['\$id']?.toString();
    final photoUrl = child['photoUrl']?.toString();
    
    // Delete from local first
    list.removeAt(index);
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
    
    // Then delete from Appwrite if it has an ID
    if (childId != null && childId.isNotEmpty) {
      try {
        await ChildService.instance.deleteChild(
          childId: childId,
          photoUrl: photoUrl,
        );
        debugPrint('✅ Child deleted from Appwrite: $childId');
      } catch (e) {
        debugPrint('⚠️ Failed to delete from Appwrite (will retry later): $e');
      }
    }
  }
  
  /// Trip status cache for each child - stores today's trip state
  /// Key: childId, Value: AbsentButtonState
  final RxMap<String, AbsentButtonState> _childTripStates = <String, AbsentButtonState>{}.obs;
  
  /// Counter to trigger UI refresh when trip states change
  final _tripStatesVersion = 0.obs;
  
  /// Get the trip states version (use in Obx to trigger rebuilds)
  int get tripStatesVersion => _tripStatesVersion.value;
  
  /// Get the absent button state for a child
  AbsentButtonState getAbsentButtonState(int index) {
    // Access the version to ensure this getter triggers Obx rebuilds
    _tripStatesVersion.value;
    
    if (index < 0 || index >= children.length) return AbsentButtonState.noTrips;
    final child = children[index];
    final childId = child['id']?.toString() ?? child['\$id']?.toString();
    if (childId == null) return AbsentButtonState.noService;
    return _childTripStates[childId] ?? AbsentButtonState.loading;
  }
  
  /// Load trip states for all children (call after loadChildren)
  /// Updates UI incrementally as each child's state is loaded
  Future<void> loadChildTripStates() async {
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final childId = child['id']?.toString() ?? child['\$id']?.toString();
      if (childId == null || childId.isEmpty) {
        continue;
      }
      
      try {
        // First check if child has an active service
        final hasService = await ActiveServiceService.instance.childHasActiveService(childId);
        if (!hasService) {
          _childTripStates[childId] = AbsentButtonState.noService;
          _tripStatesVersion.value++; // Trigger UI update
          continue;
        }
        
        final tripsResult = await TripService.instance.getChildTodayTrips(childId: childId);
        
        if (!tripsResult.success || tripsResult.trips.isEmpty) {
          _childTripStates[childId] = AbsentButtonState.noTrips;
          _tripStatesVersion.value++; // Trigger UI update
          continue;
        }
        
        // Check trip statuses
        final trips = tripsResult.trips;
        final statuses = trips.map((t) => t['status']?.toString() ?? '').toList();
        
        // If any trip is already absent
        if (statuses.any((s) => s == 'absent')) {
          _childTripStates[childId] = AbsentButtonState.alreadyAbsent;
          _tripStatesVersion.value++; // Trigger UI update
          continue;
        }
        
        // If all trips are completed (dropped) or cancelled
        final completedStatuses = ['dropped', 'cancelled'];
        if (statuses.every((s) => completedStatuses.contains(s))) {
          _childTripStates[childId] = AbsentButtonState.tripsCompleted;
          _tripStatesVersion.value++; // Trigger UI update
          continue;
        }
        
        // If any trip is in progress (picked, in_transit)
        final inProgressStatuses = ['picked', 'in_transit'];
        if (statuses.any((s) => inProgressStatuses.contains(s))) {
          _childTripStates[childId] = AbsentButtonState.tripInProgress;
          _tripStatesVersion.value++; // Trigger UI update
          continue;
        }
        
        // Has schedulable trips (scheduled, driver_enroute, arrived)
        final schedulableStatuses = ['scheduled', 'driver_enroute', 'arrived'];
        if (statuses.any((s) => schedulableStatuses.contains(s))) {
          _childTripStates[childId] = AbsentButtonState.canMarkAbsent;
          _tripStatesVersion.value++; // Trigger UI update
          continue;
        }
        
        _childTripStates[childId] = AbsentButtonState.noTrips;
        _tripStatesVersion.value++; // Trigger UI update
      } catch (e) {
        debugPrint('⚠️ Error loading trip state for child $childId: $e');
        _childTripStates[childId] = AbsentButtonState.noTrips;
        _tripStatesVersion.value++; // Trigger UI update
      }
    }
  }

  /// Mark a child at [index] as absent for today.
  /// This marks all today's scheduled trips for this child as absent in the backend,
  /// and stores the date locally for UI state.
  Future<void> markAbsentToday(int index) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    if (index < 0 || index >= list.length) return;
    
    final child = list[index];
    final childId = child['id']?.toString() ?? child['\$id']?.toString();
    
    // Store absent date in ISO format (YYYY-MM-DD) for local UI state
    final today = DateTime.now().toIso8601String().split('T')[0];
    list[index]['absentDate'] = today;
    
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
    
    // Mark all today's trips for this child as absent in backend
    if (childId != null && childId.isNotEmpty) {
      try {
        // Get today's trips for this child that are still in schedulable status
        final tripsResult = await TripService.instance.getChildTodayTrips(
          childId: childId,
          status: 'scheduled', // Only mark scheduled trips as absent
        );
        
        if (tripsResult.success && tripsResult.trips.isNotEmpty) {
          int markedCount = 0;
          for (final trip in tripsResult.trips) {
            final tripId = trip['id']?.toString();
            if (tripId != null) {
              final result = await TripService.instance.markAbsent(
                tripId,
                reason: 'Marked absent by parent',
              );
              if (result.success) markedCount++;
            }
          }
          debugPrint('✅ Marked $markedCount trips as absent for child: $childId');
        } else {
          debugPrint('📝 No scheduled trips found to mark absent for child: $childId');
        }
        
        // Update the trip state to reflect absence and trigger UI rebuild
        _childTripStates[childId] = AbsentButtonState.alreadyAbsent;
        _tripStatesVersion.value++; // Trigger UI update
      } catch (e) {
        debugPrint('⚠️ Failed to mark trips absent in backend: $e');
        // Local state is already updated, backend will catch up on next sync
        // Still update UI state
        _childTripStates[childId] = AbsentButtonState.alreadyAbsent;
        _tripStatesVersion.value++; // Trigger UI update
      }
    }
  }
  
  /// Clear the absent status for a child at [index].
  /// Note: This only clears local state - backend trips remain marked absent
  Future<void> clearAbsent(int index) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    if (index < 0 || index >= list.length) return;
    
    list[index].remove('absentDate');
    
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
    
    // Reload trip states to get accurate state from backend
    final childId = list[index]['id']?.toString() ?? list[index]['\$id']?.toString();
    if (childId != null) {
      // Reload this child's trip state
      loadChildTripStates();
    }
  }
  
  /// Check if child at [index] is marked absent for today.
  bool isAbsentToday(int index) {
    if (index < 0 || index >= children.length) return false;
    
    // Check from trip state (more accurate)
    final state = getAbsentButtonState(index);
    if (state == AbsentButtonState.alreadyAbsent) return true;
    
    // Fallback to local storage
    final child = children[index];
    final absentDate = child['absentDate']?.toString();
    if (absentDate == null || absentDate.isEmpty) return false;
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    return absentDate == today;
  }

  /// Sync all local draft children to Appwrite
  /// Call this when user has multiple unsaved children
  Future<bool> syncAllDraftsToBackend() async {
    final drafts = children.where((c) {
      final id = c['id']?.toString() ?? c['\$id']?.toString();
      return id == null || id.isEmpty;
    }).toList();
    
    if (drafts.isEmpty) return true;
    
    isSyncing.value = true;
    int successCount = 0;
    
    for (final draft in drafts) {
      final result = await addChildWithSync(draft);
      if (result) successCount++;
    }
    
    isSyncing.value = false;
    return successCount == drafts.length;
  }

  // -------- Typed helpers (non-breaking) --------

  /// Returns a typed view of the child at [index] without altering storage.
  ChildModel? childModelAt(int index) {
    if (index < 0 || index >= children.length) return null;
    return ChildModel.fromJson(children[index]);
  }

  /// Adds a child using the typed model while persisting the same JSON shape.
  Future<void> addChildModel(ChildModel child) async {
    await addChild(child.toJson());
  }

  /// Adds a child model and syncs to Appwrite
  Future<bool> addChildModelWithSync(ChildModel child, {File? photo}) async {
    return addChildWithSync(child.toJson(), photo: photo);
  }

  /// Updates an existing child using the typed model while keeping keys identical.
  Future<void> updateChildModel(int index, ChildModel child) async {
    await updateChild(index, child.toJson());
  }

  /// Updates child model and syncs to Appwrite
  Future<bool> updateChildModelWithSync(int index, ChildModel child, {File? photo}) async {
    return updateChildWithSync(index, child.toJson(), photo: photo);
  }

  /// Typed delete variant for future use if models include IDs.
  Future<void> deleteChildModel(int index) async {
    await deleteChild(index);
  }
  
  /// Get child photo URL from Appwrite storage
  String? getChildPhotoUrl(int index, {int? size}) {
    if (index < 0 || index >= children.length) return null;
    final child = children[index];
    final fileId = child['photoFileId']?.toString();
    return ChildService.instance.getChildPhotoUrl(fileId, size: size);
  }
}
