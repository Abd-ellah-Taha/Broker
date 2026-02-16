import '../../core/constants/app_constants.dart';
import '../../domain/models/property_model.dart';
import 'property_repository.dart';

/// In-memory implementation for Phase 1.
/// Replace with Firestore implementation in Phase 2.
class PropertyRepositoryImpl implements PropertyRepository {
  PropertyRepositoryImpl._();
  static final PropertyRepositoryImpl _instance = PropertyRepositoryImpl._();
  factory PropertyRepositoryImpl() => _instance;

  static final List<PropertyModel> _mockProperties = [
    PropertyModel(
      id: '1',
      title: 'Modern 3BR Apartment in New Cairo',
      description:
          'Spacious apartment with modern finishes, large windows, and parking. Close to malls and schools.',
      price: 4500000,
      category: AppConstants.categoryResidential,
      location: const PropertyLocation(
        latitude: 30.0444,
        longitude: 31.2357,
        address: 'Fifth Settlement, New Cairo',
        city: 'Cairo',
        governorate: 'Cairo',
      ),
      ownerId: 'owner-1',
      area: 180,
      imageUrls: [],
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    PropertyModel(
      id: '2',
      title: 'Commercial Office Space - Heliopolis',
      description: 'Premium office space with meeting rooms and reception. Ideal for startups.',
      price: 12000,
      category: AppConstants.categoryCommercial,
      location: const PropertyLocation(
        latitude: 30.0889,
        longitude: 31.3197,
        address: 'Roxy Square, Heliopolis',
        city: 'Cairo',
        governorate: 'Cairo',
      ),
      ownerId: 'owner-2',
      area: 120,
      imageUrls: [],
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    PropertyModel(
      id: '3',
      title: 'Cozy 2BR Villa in 6th of October',
      description: 'Villa with garden and private pool. Perfect for families.',
      price: 8500000,
      category: AppConstants.categoryResidential,
      location: const PropertyLocation(
        latitude: 29.9615,
        longitude: 30.9289,
        address: 'Sheikh Zayed, 6th of October',
        city: 'Giza',
        governorate: 'Giza',
      ),
      ownerId: 'owner-3',
      area: 350,
      imageUrls: [],
      isVerified: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Stream<List<PropertyModel>> watchProperties({String? searchQuery}) async* {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    var list = List<PropertyModel>.from(_mockProperties);
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              (p.location.address?.toLowerCase().contains(q) ?? false) ||
              (p.location.city?.toLowerCase().contains(q) ?? false) ||
              (p.location.governorate?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    yield list;
  }

  @override
  Future<PropertyModel?> getPropertyById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _mockProperties.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> createProperty(PropertyModel property) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final id = (_mockProperties.length + 1).toString();
    _mockProperties.add(property.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    return id;
  }

  @override
  Future<void> updateProperty(PropertyModel property) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final i = _mockProperties.indexWhere((p) => p.id == property.id);
    if (i >= 0) {
      _mockProperties[i] = property.copyWith(updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> deleteProperty(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _mockProperties.removeWhere((p) => p.id == id);
  }
}
