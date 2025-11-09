import 'package:flutter/material.dart';

class Mydetails extends StatelessWidget {
  const Mydetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // SafeArea background color
          Container(
            color: const Color(0xFF13688B),
            height: MediaQuery.of(context).padding.top,
          ),
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              "My Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

          ),


          // Grid content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  buildCard("Advance Request"),
                  buildCard("Salary Report"),
                  buildCard("Attendance Report"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.purple.shade100,
            child: Icon(Icons.local_gas_station, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}
