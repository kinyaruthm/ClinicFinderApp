import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '/screens/pages/location_service.dart';

//this module loads clinics directly form the map
class ClinicMapPage extends StatefulWidget {
  const ClinicMapPage({Key? key}) : super(key: key);

  @override
  State<ClinicMapPage> createState() => _ClinicMapPageState();
}

class _ClinicMapPageState extends State<ClinicMapPage> {
  late GoogleMapController _mapController;
  LatLng? _userLatLng;
  Set<Marker> _clinicMarkers = {};

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        setState(() {
          _userLatLng = null;
          _clinicMarkers = {};
        });
        return;
      }

      final LatLng userLocation = LatLng(position.latitude, position.longitude);

      List<Map<String, dynamic>> mockClinics = [
        {
          "name": "Free Clinic A",
          "lat": position.latitude + 0.002,
          "lng": position.longitude + 0.002,
        },
        {
          "name": "Affordable Clinic B",
          "lat": position.latitude - 0.003,
          "lng": position.longitude - 0.001,
        },
      ];

      Set<Marker> markers = mockClinics.map((clinic) {
        return Marker(
          markerId: MarkerId(clinic['name']),
          position: LatLng(clinic['lat'], clinic['lng']),
          infoWindow: InfoWindow(title: clinic['name']),
        );
      }).toSet();

      setState(() {
        _userLatLng = userLocation;
        _clinicMarkers = markers;
      });
    } catch (e) {
      print("Error loading map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Clinics")),
      body: _userLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLatLng!,
                zoom: 15,
              ),
              markers: _clinicMarkers,
              myLocationEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
            ),
    );
  }
}
