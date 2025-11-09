import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class StationDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> stations;

  const StationDetailsPage({super.key, required this.stations});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(Uri.encodeFull(url));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('❌ Could not launch $uri');
    }
  }

  void _shareStationDetails(Map<String, dynamic> station) {
    final String stationName = station['station_name']?.toString() ?? 'N/A';
    final String phoneNumber = station['phone']?.toString() ?? 'N/A';
    final String mapLink = station['map_link']?.toString() ?? 'N/A';

    final String text =
        "Station: $stationName\nPhone: $phoneNumber\nMap: $mapLink";

    Share.share(text, subject: 'Station Details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Station Details"),
        backgroundColor: const Color(0xFF43A047),
      ),
      body: stations.isEmpty
          ? const Center(
        child: Text(
          "No station details found!",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You are allocated to ${stations.length} filling station(s).",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                final stationName = station['station_name']?.toString() ?? 'N/A';
                final phone = station['phone']?.toString() ?? '';
                final mapLink = station['map_link']?.toString() ?? '';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stationName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF13688B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (phone.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.phone,
                            text: 'Phone: $phone',
                            onTap: () => _launchUrl('tel:$phone'),
                          ),
                        const SizedBox(height: 8),
                        if (mapLink.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.map,
                            text: 'Map Link',
                            onTap: () => _launchUrl(mapLink),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _shareStationDetails(station),
                            icon: const Icon(Icons.share, color: Colors.white),
                            label: const Text(
                              "Share Details",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4DB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
