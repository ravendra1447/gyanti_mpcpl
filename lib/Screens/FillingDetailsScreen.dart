import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import 'fillingdetailsupdatepage.dart';

class FillingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> fillingData;

  const FillingDetailsScreen({super.key, required this.fillingData});

  @override
  State<FillingDetailsScreen> createState() => _FillingDetailsScreenState();
}

class _FillingDetailsScreenState extends State<FillingDetailsScreen> {

  final TextEditingController _otpController = TextEditingController();
  bool _isSubmitting = false;


  Future<void> _submitOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final staffId = prefs.getString('staff_id');
    final requestId = widget.fillingData['id'];
    final otp = _otpController.text.trim();

    print("Request ID: $requestId");
    print("Staff ID (from SharedPreferences): $staffId");

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter OTP")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final url = Uri.parse("${ApiConstants.baseUrl}/freq_otp_check");

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'staff_id': staffId.toString(),
          'request_id': requestId.toString(),
          'otp': otp,
        },
      );

      final result = json.decode(response.body);
      print("API Response: $result");

      if (response.statusCode == 200 && result['msg'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Verified")),
        );

        // Navigate to Filling Request Update Page
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => FillingRequestUpdatePage(
        //       // requestId: requestId.toString(),
        //       // staffId: staffId.toString(),
        //       fillingData: widget.fillingData, // passing entire map
        //     ),
        //   ),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['msg'] ?? "Verification Failed")),
        );
      }
    } catch (e) {
      print("API Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF13688B), // Blue background outside SafeArea
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 1),
            child: Column(
              children: [
                AppBar(
                  title: const Text("Filling Details"),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Box 1 ---
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      infoRow("OTP", widget.fillingData['otp']),
                      infoRow("Request ID", widget.fillingData['rid']),
                      infoRow("Vehicle Number", widget.fillingData['vehicle_number']),
                      infoRow("Product Name", widget.fillingData['product_name']),
                      infoRow("Loading Station", widget.fillingData['station_name']),
                      infoRow("Customer Name", widget.fillingData['customer_name']),
                      // infoRow("Quantity", widget.fillingData['qty'] ?? "N/A"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- Note ---
                const Text(
                  "Note: Recheck details for particular vehicle number",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // --- Box 2: OTP input ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          "Enter Otp",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.black26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            border: InputBorder.none,
                            hintText: "Enter otp",
                            hintStyle: TextStyle(color: Colors.red),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- Submit Button ---
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF19567A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: _isSubmitting ? null : _submitOtp,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Submit",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }

  Widget infoRow(String label, dynamic value,
      {Color textColor = Colors.black87, bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          // Vertical divider
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
}

