import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Upload images to Firebase Storage.
class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final _picker = ImagePicker();

  Future<List<XFile>> pickImages({int max = 5}) async {
    final picked = await _picker.pickMultiImage();
    return picked.take(max).toList();
  }

  Future<String> uploadPropertyImage({
    required String propertyId,
    required XFile file,
    required String userId,
  }) async {
    final bytes = await file.readAsBytes();
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('properties/$propertyId/$userId/$name');
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }

  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required List<XFile> files,
    required String userId,
  }) async {
    final urls = <String>[];
    for (final f in files) {
      final url = await uploadPropertyImage(
        propertyId: propertyId,
        file: f,
        userId: userId,
      );
      urls.add(url);
    }
    return urls;
  }
}
