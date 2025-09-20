import 'dart:async';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:poafix/core/models/provider.dart';
import 'package:poafix/core/services/location_service.dart';
import 'package:poafix/core/enums/service_category.dart';
import 'package:poafix/features/map/widgets/map_search_bar.dart';
import 'package:poafix/features/map/widgets/service_category_filters.dart';
import 'package:poafix/features/map/widgets/provider_details_sheet.dart';

class MapScreen extends StatefulWidget {
  final String? categoryId;
  final String? serviceId;

  const MapScreen({Key? key, this.categoryId, this.serviceId})
    : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};

  late AnimationController _bottomSheetController;
  Provider? _selectedProvider;
  ServiceCategory? _selectedCategory;
  LatLng? _userLocation;
  bool _isLoading = true;
  bool _isLoadingProviders = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _moveCamera(_userLocation!);
      _loadNearbyProviders();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _moveCamera(LatLng position) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14.0),
      ),
    );
  }

  void _loadNearbyProviders() {
    if (_userLocation == null) return;

    setState(() => _isLoadingProviders = true);

    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Debounce the provider loading to prevent too many requests
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _locationService
          .getNearbyProviders(
            _userLocation!.latitude,
            _userLocation!.longitude,
            5.0, // Fixed 5km radius
            _selectedCategory,
          )
          .listen(
            (providers) {
              _updateMarkers(providers);
              setState(() => _isLoadingProviders = false);
            },
            onError: (e) {
              print('Error loading providers: $e');
              setState(() => _isLoadingProviders = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading service providers'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
    });
  }

  void _updateMarkers(List<Provider> providers) {
    setState(() {
      _markers.clear();
      for (final provider in providers) {
        if (provider.location != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(provider.id),
              position: LatLng(
                provider.location!.latitude,
                provider.location!.longitude,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _selectedCategory == null
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueAzure,
              ),
              onTap: () => _onMarkerTapped(provider),
            ),
          );
        }
      }
    });
  }

  void _onMarkerTapped(Provider provider) {
    setState(() {
      _selectedProvider = provider;
    });
    _bottomSheetController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _userLocation ?? const LatLng(0, 0),
                    zoom: 14.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: MapSearchBar(
                          onSearch: (location) {
                            if (location != null) {
                              _moveCamera(location);
                              setState(() {
                                _userLocation = location;
                              });
                              _loadNearbyProviders();
                            }
                          },
                        ),
                      ),
                      ServiceCategoryFilters(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() => _selectedCategory = category);
                          _loadNearbyProviders();
                        },
                      ),
                      if (_isLoadingProviders)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
                if (_selectedProvider != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ProviderDetailsSheet(
                      provider: _selectedProvider!,
                      controller: _bottomSheetController,
                      onClose: () {
                        _bottomSheetController.reverse().then((_) {
                          if (mounted) {
                            setState(() {
                              _selectedProvider = null;
                            });
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _bottomSheetController.dispose();
    super.dispose();
  }
}
