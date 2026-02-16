import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/property_model.dart';
import 'property_repository.dart';

class PropertyRepositoryFirestore implements PropertyRepository {
  PropertyRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collection = 'properties';

  @override
  Stream<List<PropertyModel>> watchProperties({String? searchQuery}) {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snap) {
      var list = snap.docs
          .map((doc) {
            try {
              return PropertyModel.fromJson({'id': doc.id, ...doc.data()});
            } catch (_) {
              return null;
            }
          })
          .whereType<PropertyModel>()
          .toList();
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list.where((p) {
          return p.title.toLowerCase().contains(q) ||
              (p.location.address?.toLowerCase().contains(q) ?? false) ||
              (p.location.city?.toLowerCase().contains(q) ?? false) ||
              (p.location.governorate?.toLowerCase().contains(q) ?? false) ||
              p.description.toLowerCase().contains(q);
        }).toList();
      }
      return list;
    });
  }

  @override
  Future<PropertyModel?> getPropertyById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return PropertyModel.fromJson({'id': doc.id, ...doc.data()!});
    }
    return null;
  }

  @override
  Future<String> createProperty(PropertyModel property) async {
    final data = property.toJson();
    data.remove('id');
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    final ref = await _firestore.collection(_collection).add(data);
    return ref.id;
  }

  @override
  Future<void> updateProperty(PropertyModel property) async {
    final data = property.toJson();
    data.remove('id');
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _firestore.collection(_collection).doc(property.id).set(
          data,
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteProperty(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> setVerified(String id, bool verified) async {
    await _firestore.collection(_collection).doc(id).update({
      'isVerified': verified,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<PropertyModel>> watchPropertiesByOwner(String ownerId) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PropertyModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

}
