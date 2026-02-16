import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../data/repositories/property_repository.dart';
import '../../data/repositories/property_repository_firestore.dart';
import '../../data/repositories/property_repository_impl.dart';
import '../../domain/models/property_model.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return useFirestore ? PropertyRepositoryFirestore() : PropertyRepositoryImpl();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final propertiesProvider = StreamProvider<List<PropertyModel>>((ref) {
  final repo = ref.watch(propertyRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  return repo.watchProperties(searchQuery: query.isEmpty ? null : query);
});

final propertyByIdProvider =
    FutureProvider.family<PropertyModel?, String>((ref, id) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getPropertyById(id);
});

final createPropertyProvider =
    FutureProvider.family<String, PropertyModel>((ref, property) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.createProperty(property);
});
