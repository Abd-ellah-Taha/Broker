class AppConstants {
  AppConstants._();

  static const String appName = 'Broker';
  static const String appTagline = 'PropTech Marketplace';

  // Map defaults (Cairo, Egypt)
  static const double defaultLatitude = 30.0444;
  static const double defaultLongitude = 31.2357;
  static const double defaultZoom = 12.0;

  // Property categories
  static const String categoryResidential = 'residential';
  static const String categoryCommercial = 'commercial';

  static const List<String> propertyCategories = [
    categoryResidential,
    categoryCommercial,
  ];

  // User roles
  static const String roleSeeker = 'seeker';
  static const String roleOwner = 'owner';
  static const String roleAdmin = 'admin';
}
