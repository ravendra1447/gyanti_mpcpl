import 'package:flutter/material.dart';
import 'FillingDetailsScreen.dart';

class FillingRequestPage extends StatelessWidget {
  final List<Map<String, dynamic>> requestList;

  const FillingRequestPage({super.key, required this.requestList});

  @override
  Widget build(BuildContext context) {
    // ab koi status filter nahi hoga, sabhi data vehicle number ke hisaab se dikhega
    final filteredList = requestList;

    return Container(
      color: const Color(0xFF13688B),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 1),
            child: Column(
              children: [
                AppBar(
                  title: const Text("Filling Requests"),
                  leading: const BackButton(),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
                Container(height: 1, color: Colors.grey.shade300),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Vehicle number display
                RichText(
                  text: TextSpan(
                    text: 'Search Results for ',
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    children: [
                      TextSpan(
                        text: requestList.isNotEmpty
                            ? requestList[0]['vehicle_number'] ?? ''
                            : '',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                filteredList.isEmpty
                    ? const Center(
                  child: Text(
                    "No requests found.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final fillingData = filteredList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              infoRow("Request Id", fillingData['rid']),
                              infoRow("Vehicle Number", fillingData['vehicle_number']),
                              infoRow("Product", fillingData['product_name']),
                              infoRow("Loading Station", fillingData['station_name']),
                              infoRow("Client Name", fillingData['customer_name']),
                              infoRow("Driver Phone", fillingData['driver_number']),
                              infoRow("Date & Time", fillingData['created']),
                              infoRow("Status", fillingData['status'],
                                  textColor: Colors.orange, isBold: true),
                              infoRow("Eligibility",
                                  fillingData['eligibility'] == 'Yes' ? 'Yes' : 'No',
                                  textColor: Colors.green),
                              actionRow(context, fillingData),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // reusable info row
  Widget infoRow(String label, dynamic value,
      {Color textColor = Colors.black87, bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey.shade400,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value?.toString() ?? "-",
              style: TextStyle(
                color: textColor,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // action buttons row
  Widget actionRow(BuildContext context, Map fillingData) {
    bool isEligible = fillingData['eligibility'] == 'Yes';

    return isEligible
        ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FillingDetailsScreen(
                    fillingData: fillingData.cast<String, dynamic>(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.green),
            onPressed: () {
              // future me yaha message action add karna hai
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
    )
        : const SizedBox();
  }
}
