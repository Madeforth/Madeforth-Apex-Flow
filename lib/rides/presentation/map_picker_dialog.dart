import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/rides/domain/meeting_point.dart';
import 'package:apexflow/rides/application/nominatim_search_service.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class MapPickerDialog extends StatefulWidget {
  const MapPickerDialog({super.key, required this.tr});

  final bool tr;

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  final NominatimSearchService _searchService = NominatimSearchService();
  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng _selectedLatLng = const LatLng(41.0082, 28.9784); // Istanbul default
  String _selectedName = '';

  List<MeetingPoint> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  // Custom Dark Mode Map Style
  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#121212"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#8a8a8a"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#121212"
        }
      ]
    },
    {
      "featureType": "administrative.land_parcel",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#1c1c1c"
        }
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#2c2c2c"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#0d1b2a"
        }
      ]
    }
  ]
  ''';

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _searchResults = [];
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final results = await _searchService.search(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  void _selectSearchResult(MeetingPoint point) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLatLng = LatLng(point.latitude, point.longitude);
      _selectedName = point.name;
      _searchResults = [];
      _searchController.text = point.name;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedLatLng, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          tInline(
            AppStrings.currentLanguageCode,
            'Buluşma Noktası Seç',
            'Select Meeting Point',
            'Wählen Sie Treffpunkt',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Google Map Background
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLatLng,
              zoom: 12,
            ),
            style: _darkMapStyle,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected_meeting_point'),
                position: _selectedLatLng,
                infoWindow: InfoWindow(
                  title: _selectedName.isEmpty
                      ? (tInline(
                          AppStrings.currentLanguageCode,
                          'Seçilen Konum',
                          'Selected Location',
                          'Ausgewählter Standort',
                        ))
                      : _selectedName,
                ),
              ),
            },
            onTap: (latLng) {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedLatLng = latLng;
                _selectedName = tInline(
                  AppStrings.currentLanguageCode,
                  'İğne ile Seçilen Konum',
                  'Pinned Location',
                  'Angepinnter Standort',
                );
              });
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Search overlay input and list
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search Input Field
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    border: Border.all(color: context.colors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: context.colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: tInline(
                        AppStrings.currentLanguageCode,
                        'Konum ara...',
                        'Search location...',
                        'Standort suchen...',
                      ),
                      hintStyle: TextStyle(color: context.colors.textSecondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.colors.textSecondary,
                      ),
                      suffixIcon: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    context.colors.cyan,
                                  ),
                                ),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: context.colors.textSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                // Search Results List
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(ApexSpacing.radius),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: context.colors.border, height: 1),
                      itemBuilder: (context, index) {
                        final point = _searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: context.colors.cyan,
                            size: 18,
                          ),
                          title: Text(
                            point.name,
                            style: TextStyle(
                              color: context.colors.white,
                              fontSize: 13,
                            ),
                          ),
                          onTap: () => _selectSearchResult(point),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.cyan,
                  foregroundColor: context.colors.onAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  ),
                  elevation: 6,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final String finalName = _selectedName.isNotEmpty
                      ? _selectedName
                      : (tInline(
                          AppStrings.currentLanguageCode,
                          'Koordinat Noktası',
                          'Coordinate Point',
                          'Koordinatenpunkt',
                        ));

                  Navigator.pop(
                    context,
                    MeetingPoint(
                      name: finalName,
                      latitude: _selectedLatLng.latitude,
                      longitude: _selectedLatLng.longitude,
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Konumu Onayla',
                    'Confirm Location',
                    'Standort bestätigen',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
