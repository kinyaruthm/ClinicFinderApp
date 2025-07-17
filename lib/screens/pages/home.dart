import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '/screens/pages/location_service.dart';
import '/screens/pages/clinic_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:clinicfinder/components.dart';

//landing page that displays all available clinics already saved in the database
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _location = "Fetching location...";
  Position? _userPosition;

  List<Map<String, dynamic>> _nearbyClinics = [];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      Position? position = await LocationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _userPosition = position;
          _location = "Lat: ${position.latitude}, Long: ${position.longitude}";
        });

        await _loadClinicsFromFirestore(position);
      } else {
        setState(() {
          _location = "Location not available.";
        });
      }
    } catch (e) {
      setState(() {
        _location = "Error: $e";
      });
    }
  }

  //save clinics to the db
  final List<Map<String, dynamic>> sampleClinics = [
    {
      "name": "Kawangware Health Center",
      "address": "Kawangware Lane",
      "lat": -1.2505,
      "lng": 36.6818,
      "isFree": true,
    },
    {
      "name": "Riruta Satellite Clinic",
      "address": "Kabiria Road",
      "lat": -1.2521,
      "lng": 36.6783,
      "isFree": false,
    },
    {
      "name": "Waithaka Health Post",
      "address": "Waithaka Road",
      "lat": -1.2532,
      "lng": 36.6831,
      "isFree": true,
    },
    {
      "name": "Nairobi West Medical",
      "address": "Nairobi West",
      "lat": -1.2501,
      "lng": 36.6799,
      "isFree": false,
    },
    {
      "name": "Dagoretti Community Health",
      "address": "Dagoretti Corner",
      "lat": -1.2545,
      "lng": 36.6822,
      "isFree": true,
    },
  ];

  Future<void> uploadSampleClinics() async {
    final clinicsRef = FirebaseFirestore.instance.collection('clinics');

    for (var clinic in sampleClinics) {
      await clinicsRef.add(clinic);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Clinics uploaded successfully!')),
    );

    if (_userPosition != null) {
      await _loadClinicsFromFirestore(_userPosition!);
    }
  }

  Future<void> _loadClinicsFromFirestore(Position position) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .get();

      List<Map<String, dynamic>> nearby = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final double lat = data['lat'];
        final double lng = data['lng'];

        double distance = _calculateDistance(
          position.latitude,
          position.longitude,
          lat,
          lng,
        );

        if (distance <= 10) {
          nearby.add({
            'name': data['name'],
            'address': data['address'],
            'lat': lat,
            'lng': lng,
            'isFree': data['isFree'] ?? false,
            'distance': "${distance.toStringAsFixed(2)} km",
          });
        }
      }

      setState(() {
        _nearbyClinics = nearby;
      });
    } catch (e) {
      print("Error fetching clinics: $e");
    }
  }

  void _searchClinicsByLocation() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .get();

      List<Map<String, dynamic>> matchedClinics = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final String name = data['name']?.toLowerCase() ?? '';
        final String address = data['address']?.toLowerCase() ?? '';

        if (name.contains(query) || address.contains(query)) {
          matchedClinics.add({
            'name': data['name'],
            'address': data['address'],
            'lat': data['lat'],
            'lng': data['lng'],
            'isFree': data['isFree'] ?? false,
            'distance': '–',
          });
        }
      }

      setState(() {
        _nearbyClinics = matchedClinics;
      });
    } catch (e) {
      print("Error during search: $e");
    }
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    const p = 0.0174533;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clinic Finder"),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${user?.displayName ?? 'User'} 👋",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(_location, style: const TextStyle(color: Colors.teal)),
            const SizedBox(height: 20),

            // Search row
            Row(
              children: [
                Expanded(
                  //reused textfield
                  child: AppTextField(
                    controller: _searchController,
                    //decoration: InputDecoration(
                    label: 'Search location',
                    // border: const OutlineInputBorder(),
                    // isDense: true,
                    //icon: IconButton(
                    //icon: const Icon(icon.),
                    // onPressed: () {
                    //   _searchController.clear();
                    //   if (_userPosition != null) {
                    //     _loadClinicsFromFirestore(_userPosition!);
                    //   }
                    // },
                    // ),
                    // ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchClinicsByLocation,
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            //uploads the sample clinics once

            // Upload button -commented to prevent uploading twice
            // ElevatedButton.icon(
            //   onPressed: uploadSampleClinics,
            //   icon: const Icon(Icons.cloud_upload),
            //   label: const Text("Upload Sample Clinics"),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.deepPurple,
            //   ),
            // ),
            const SizedBox(height: 20),
            const Text(
              "Nearby Clinics",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _nearbyClinics.isEmpty
                  ? const Center(child: Text("No clinics found"))
                  : ListView.builder(
                      itemCount: _nearbyClinics.length,
                      itemBuilder: (context, index) {
                        final clinic = _nearbyClinics[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.local_hospital,
                              color: Colors.teal,
                            ),
                            title: Text(clinic['name'] ?? ''),
                            subtitle: Text(
                              "${clinic['address'] ?? ''} • ${clinic['distance'] ?? ''}",
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ClinicDetailsPage(clinic: clinic),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
