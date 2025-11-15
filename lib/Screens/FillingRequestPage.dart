import 'package:flutter/material.dart';
import 'FillingDetailsScreen.dart';

class FillingRequestPage extends StatefulWidget {
  final List<Map<String, dynamic>> requestList;

  const FillingRequestPage({super.key, required this.requestList});

  @override
  State<FillingRequestPage> createState() => _FillingRequestPageState();
}

class _FillingRequestPageState extends State<FillingRequestPage> {
  late List<Map<String, dynamic>> filteredList;

  @override
  void initState() {
    super.initState();
    filteredList = List<Map<String, dynamic>>.from(widget.requestList);
  }

  @override
  Widget build(BuildContext context) {

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
                        text: filteredList.isNotEmpty
                            ? filteredList[0]['vehicle_number'] ?? ''
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
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              infoRow("Request Id", fillingData['rid'] ?? fillingData['id']),
                              infoRow("Vehicle Number", fillingData['vehicle_number']),
                              infoRow("Product", fillingData['product_name']),
                              infoRow("Loading Station", fillingData['station_name']),
                              infoRow("Client Name", fillingData['customer_name']),
                              infoRow("Driver Phone", fillingData['driver_number'] ?? fillingData['driver_phone'] ?? fillingData['customer_phone']),
                              infoRow("Date & Time", fillingData['created'] ?? fillingData['created_at']),
                              _statusRow(fillingData['status']),
                              ((fillingData['status']?.toString().toLowerCase() ?? '') == 'pending')
                                  ? infoRow(
                                      "Eligibility",
                                      computeEligibility(fillingData) ? 'Yes' : 'No',
                                      textColor: Colors.green,
                                    )
                                  : const SizedBox.shrink(),
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
    final status = (fillingData['status']?.toString().toLowerCase() ?? '');
    bool isPending = status == 'pending';
    bool isProcessing = status == 'processing';
    bool isEligible = isPending ? computeEligibility(fillingData) : false;

    return ((isEligible && isPending) || isProcessing)
        ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Colors.green),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FillingDetailsScreen(
                    fillingData: fillingData.cast<String, dynamic>(),
                  ),
                ),
              );
              if (result is Map && (result['id'] != null || result['rid'] != null)) {
                final uid = (result['id'] ?? result['rid']).toString();
                final idx = filteredList.indexWhere((e) =>
                    (e['id']?.toString() ?? e['rid']?.toString() ?? '') == uid);
                if (idx != -1) {
                  setState(() {
                    filteredList[idx]['status'] = (result['status'] ?? 'Completed');
                    if (result['aqty'] != null) {
                      filteredList[idx]['aqty'] = result['aqty'];
                    }
                  });
                }
              }
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

  bool computeEligibility(Map data) {
    final status = (data['status']?.toString().toLowerCase() ?? '');
    if (status != 'pending') return false;
    final price = _toDouble(data['price'] ?? data['deal_price']);
    final qty = _toDouble(data['qty'] ?? data['aqty']);
    final amtlimit = _toDouble(data['amtlimit']);
    if (price <= 0) return false;
    final total = price * qty;
    return amtlimit >= total;
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  Color statusColor(dynamic s) {
    final status = (s?.toString().toLowerCase() ?? '');
    if (status == 'completed') return Colors.green;
    if (status == 'processing' || status == 'pending') return Colors.orange;
    return Colors.black87;
  }

  Widget _statusRow(dynamic s) {
    final v = (s ?? '-').toString();
    final c = statusColor(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(height: 20, width: 1, color: Colors.grey.shade400, margin: const EdgeInsets.symmetric(horizontal: 8)),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    v.toLowerCase() == 'completed' ? Icons.check_circle : Icons.timelapse,
                    color: c,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(v, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
