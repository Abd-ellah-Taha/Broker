import '../../domain/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserById(String id);
  Future<void> createOrUpdateUser(UserModel user);
  Stream<UserModel?> watchUser(String id);
}
