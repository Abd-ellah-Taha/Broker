import '../../domain/models/property_model.dart';

/// Repository for property CRUD operations.
abstract class PropertyRepository {
  Stream<List<PropertyModel>> watchProperties({String? searchQuery});
  Future<PropertyModel?> getPropertyById(String id);
  Future<String> createProperty(PropertyModel property);
  Future<void> updateProperty(PropertyModel property);
  Future<void> deleteProperty(String id);
}
