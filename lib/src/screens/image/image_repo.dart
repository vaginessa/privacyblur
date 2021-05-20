import 'package:privacyblur/src/data/services/heap_size.dart';
import 'package:privacyblur/src/data/services/local_storage.dart';

class ImageRepository {
  final LocalStorage _storage;
  final HeapSize _heapSize;

  ImageRepository(this._storage, this._heapSize);

  Future<bool> setLastPath(String path) {
    return _storage.setLastPath(path);
  }

  Future<String> getLastPath() {
    return _storage.getLastPath();
  }

  Future<bool> removeLastPath() {
    return _storage.removeLastPath();
  }

  Future<int> getHeapSize() async {
    var value = await _heapSize.getSize();
    if (value is int) {
      return Future.value(value);
    } else {
      return Future.value(-1);
    }
  }
}
