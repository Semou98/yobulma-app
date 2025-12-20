// lib/screens/map/map_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/location_model.dart';
import '../../utils/constants.dart';

class MapSelectionScreen extends StatefulWidget {
  final LocationPoint? initialLocation;
  final String? quartier;

  const MapSelectionScreen({
    super.key,
    this.initialLocation,
    this.quartier,
  });

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  bool _isLoading = true;
  bool _hasPermission = false;
  String _address = '';
  final double _zoomLevel = 15.0;
  
  // Position par défaut de Dakar
  static const LatLng _dakarCenter = LatLng(14.716677, -17.467686);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Vérifier la permission de localisation
    final permission = await Geolocator.checkPermission();
    final isPermissionGranted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    setState(() {
      _hasPermission = isPermissionGranted;
    });

    if (isPermissionGranted) {
      await _getCurrentLocation();
    } else {
      // Demander la permission
      final requestedPermission = await Geolocator.requestPermission();
      final isGranted = requestedPermission == LocationPermission.always ||
          requestedPermission == LocationPermission.whileInUse;
      
      if (isGranted && mounted) {
        await _getCurrentLocation();
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedPosition = widget.initialLocation != null
              ? LatLng(widget.initialLocation!.latitude,
                  widget.initialLocation!.longitude)
              : _dakarCenter;
          _mapController.move(_selectedPosition!, _zoomLevel);
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _selectedPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        
        _mapController.move(_selectedPosition!, _zoomLevel);
        await _reverseGeocode(_selectedPosition!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedPosition = widget.initialLocation != null
              ? LatLng(widget.initialLocation!.latitude,
                  widget.initialLocation!.longitude)
              : _dakarCenter;
        });
        _mapController.move(_selectedPosition!, _zoomLevel);
      }
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final address = await _getAddressFromCoordinates(
          position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _address = address;
        });
      }
    } catch (e) {
      debugPrint('Erreur géocodage: $e');
    }
  }

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    // Service de géocodage simple
    return 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
  }

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _selectedPosition = latLng;
    });
    _reverseGeocode(latLng);
  }

  void _confirmSelection() {
    if (_selectedPosition != null) {
      final location = LocationPoint(
        latitude: _selectedPosition!.latitude,
        longitude: _selectedPosition!.longitude,
        address: _address.isNotEmpty ? _address : null,
        quartier: widget.quartier,
      ); // Supprimé le paramètre timestamp s'il n'existe pas dans LocationPoint
      
      Navigator.pop(context, location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner une adresse'),
        actions: [
          if (_selectedPosition != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmSelection,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _selectedPosition ?? _dakarCenter,
                    zoom: _zoomLevel,
                    onTap: _onMapTap,
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    // Tile layer OpenStreetMap
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.yoboulma',
                    ),
                    
                    // Marker layer
                    MarkerLayer(
                      markers: [
                        if (_selectedPosition != null)
                          Marker(
                            point: _selectedPosition!,
                            width: 40,
                            height: 40,
                            builder: (context) => const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                // Position actuelle
                Positioned(
                  bottom: 100,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                
                // Info de position
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Position sélectionnée:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedPosition != null
                                ? 'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}\n'
                                    'Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}'
                                : 'Appuyez sur la carte',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (_address.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Adresse: $_address',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}