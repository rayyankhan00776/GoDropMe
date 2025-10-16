import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

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
    await LocalStorage.setJsonList(StorageKeys.childrenList, list);
    children.assignAll(list);
  }
}
