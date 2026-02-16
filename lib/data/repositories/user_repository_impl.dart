import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/user_model.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collection = 'users';

  @override
  Future<UserModel?> getUserById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson({'id': doc.id, ...doc.data()!});
    }
    return null;
  }

  @override
  Future<void> createOrUpdateUser(UserModel user) async {
    await _firestore.collection(_collection).doc(user.id).set(
          user.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Stream<UserModel?> watchUser(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    });
  }
}
