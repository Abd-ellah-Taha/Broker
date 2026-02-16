import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// User model representing both Seekers (Buyers/Tenants) and Owners (Sellers/Lessors).
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    this.email,
    this.photoUrl,
    this.role = AppConstants.roleSeeker,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String phoneNumber;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isSeeker => role == AppConstants.roleSeeker;
  bool get isOwner => role == AppConstants.roleOwner;
  bool get isAdmin => role == AppConstants.roleAdmin;

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? displayName,
    String? email,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String? ?? AppConstants.roleSeeker,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, phoneNumber, displayName, email, role];
}
