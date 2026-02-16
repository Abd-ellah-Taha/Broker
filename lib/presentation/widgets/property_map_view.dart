import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/property_model.dart';

class PropertyMapView extends StatefulWidget {
  const PropertyMapView({
    super.key,
    required this.properties,
    this.initialPosition,
    this.onPropertySelected,
  });

  final List<PropertyModel> properties;
  final LatLng? initialPosition;
  final ValueChanged<PropertyModel>? onPropertySelected;

  @override
  State<PropertyMapView> createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends State<PropertyMapView> {
  GoogleMapController? _controller;
  PropertyModel? _selectedProperty;

  static const LatLng _defaultCenter = LatLng(
    AppConstants.defaultLatitude,
    AppConstants.defaultLongitude,
  );

  Set<Marker> get _markers {
    return widget.properties.map((p) {
      final isSelected = _selectedProperty?.id == p.id;
      return Marker(
        markerId: MarkerId(p.id),
        position: LatLng(p.location.latitude, p.location.longitude),
        onTap: () {
          setState(() => _selectedProperty = p);
          widget.onPropertySelected?.call(p);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(
          p.isVerified
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueOrange,
        ),
        infoWindow: InfoWindow(
          title: p.title,
          snippet: p.formattedPrice,
        ),
      );
    }).toSet();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition ?? _defaultCenter,
          zoom: AppConstants.defaultZoom,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _controller = controller;
          _fitBoundsIfNeeded();
        },
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
      ),
    );
  }

  Future<void> _fitBoundsIfNeeded() async {
    if (_controller == null || widget.properties.isEmpty) return;

    final bounds = _computeBounds();
    if (bounds != null) {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  LatLngBounds? _computeBounds() {
    if (widget.properties.isEmpty) return null;

    var minLat = widget.properties.first.location.latitude;
    var maxLat = minLat;
    var minLng = widget.properties.first.location.longitude;
    var maxLng = minLng;

    for (final p in widget.properties) {
      if (p.location.latitude < minLat) minLat = p.location.latitude;
      if (p.location.latitude > maxLat) maxLat = p.location.latitude;
      if (p.location.longitude < minLng) minLng = p.location.longitude;
      if (p.location.longitude > maxLng) maxLng = p.location.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
