import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';

/// Geographic coordinates and address for a property.
class PropertyLocation extends Equatable {
  const PropertyLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.governorate,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? governorate;

  @override
  List<Object?> get props => [latitude, longitude, address, city, governorate];

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'city': city,
        'governorate': governorate,
      };

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      governorate: json['governorate'] as String?,
    );
  }
}

/// Property model for Residential and Commercial listings.
class PropertyModel extends Equatable {
  const PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.location,
    required this.ownerId,
    this.area,
    this.imageUrls = const [],
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final PropertyLocation location;
  final String ownerId;
  final double? area;
  final List<String> imageUrls;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isResidential => category == AppConstants.categoryResidential;
  bool get isCommercial => category == AppConstants.categoryCommercial;

  String get categoryLabel {
    switch (category) {
      case AppConstants.categoryResidential:
        return 'Residential';
      case AppConstants.categoryCommercial:
        return 'Commercial';
      default:
        return category;
    }
  }

  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'EGP ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        category,
        location,
        ownerId,
        area,
        imageUrls,
        isVerified,
        createdAt,
        updatedAt,
      ];

  PropertyModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    PropertyLocation? location,
    String? ownerId,
    double? area,
    List<String>? imageUrls,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      location: location ?? this.location,
      ownerId: ownerId ?? this.ownerId,
      area: area ?? this.area,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'location': location.toJson(),
        'ownerId': ownerId,
        'area': area,
        'imageUrls': imageUrls,
        'isVerified': isVerified,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      location: PropertyLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      ownerId: json['ownerId'] as String,
      area: (json['area'] as num?)?.toDouble(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
