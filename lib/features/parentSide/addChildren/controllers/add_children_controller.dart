import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/parentSide/addChildren/models/child.dart';

class AddChildrenController extends GetxController {
  final RxList<Map<String, dynamic>> children = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChildren();
  }

  Future<void> loadChildren() async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    for (final m in list) {
      m.remove('disabled');
    }
    children.assignAll(list);
  }

  Future<void> addChild(Map<String, dynamic> data) async {
    // Dummy persistence: local storage only; no backend calls here.
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    list.add(data);
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
  }

  Future<void> updateChild(int index, Map<String, dynamic> data) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    if (index < 0 || index >= list.length) return;
    list[index] = data;
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
  }

  /// Delete a child entry at [index] from local storage and update state.
  ///
  /// Backend integration note:
  /// When a backend is available, add a call here to delete the child
  /// document/server record before removing locally. Consider optimistic
  /// updates with rollback on failure.
  Future<void> deleteChild(int index) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
  }

  /// Mark a child at [index] as absent for today.
  /// This stores the current date in ISO format so we can track today's absence.
  ///
  /// Backend integration note:
  /// When backend is available, this should notify the driver about
  /// the child's absence via Appwrite messaging/notifications or
  /// update the trip status to 'absent'.
  Future<void> markAbsentToday(int index) async {
    final list = await LocalStorage.getJsonList(StorageKeys.childrenList);
    if (index < 0 || index >= list.length) return;
    
    // Store absent date in ISO format (YYYY-MM-DD)
    final today = DateTime.now().toIso8601String().split('T')[0];
    list[index]['absentDate'] = today;
    
    await LocalStorage.replaceJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
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

  /// Updates an existing child using the typed model while keeping keys identical.
  Future<void> updateChildModel(int index, ChildModel child) async {
    await updateChild(index, child.toJson());
  }

  /// Typed delete variant for future use if models include IDs.
  Future<void> deleteChildModel(int index) async {
    await deleteChild(index);
  }
}
