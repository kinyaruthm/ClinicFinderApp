import 'package:flutter/material.dart';
import 'review.dart';

class ClinicDetailsPage extends StatelessWidget {
  final Map<String, dynamic> clinic;

  const ClinicDetailsPage({Key? key, required this.clinic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = clinic['name'] ?? 'Unknown Clinic';
    final address = clinic['address'] ?? 'No address';
    final distance = clinic['distance'] ?? '';
    final lat = clinic['lat'];
    final lng = clinic['lng'];
    final isFree = clinic['isFree'] ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🏥 $name",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("📍 Address: $address", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            if (distance != '')
              Text(
                "📏 Distance: $distance",
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 8),
            Text(
              "💰 Cost: ${isFree ? 'Free' : 'Affordable'}",
              style: const TextStyle(fontSize: 16),
            ),
            if (lat != null && lng != null) ...[
              const SizedBox(height: 16),
              Text(
                "🗺️ Coordinates: $lat, $lng",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 4),
            ElevatedButton.icon(
              icon: const Icon(Icons.reviews),
              label: const Text("Write a Review"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReviewPage(clinicId: name, clinicName: name),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
