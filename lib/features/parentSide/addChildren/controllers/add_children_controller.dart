import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/parentSide/addChildren/models/child.dart';
import 'package:godropme/services/appwrite/child_service.dart';
import 'package:godropme/services/appwrite/parent_service.dart';
import 'package:godropme/utils/schools_loader.dart';

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

  /// Mark a child at [index] as absent for today.
  /// This stores the current date in ISO format so we can track today's absence.
  Future<void> markAbsentToday(int index) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    if (index < 0 || index >= list.length) return;
    
    // Store absent date in ISO format (YYYY-MM-DD)
    final today = DateTime.now().toIso8601String().split('T')[0];
    list[index]['absentDate'] = today;
    
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
    
    // TODO: Notify driver via Appwrite messaging when backend is ready
  }
  
  /// Clear the absent status for a child at [index].
  Future<void> clearAbsent(int index) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    if (index < 0 || index >= list.length) return;
    
    list[index].remove('absentDate');
    
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
  }
  
  /// Check if child at [index] is marked absent for today.
  bool isAbsentToday(int index) {
    if (index < 0 || index >= children.length) return false;
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
