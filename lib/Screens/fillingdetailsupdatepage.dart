// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../api_constants.dart';
//
// class FillingRequestUpdatePage extends StatefulWidget {
//   final Map<String, dynamic> fillingData;
//
//   const FillingRequestUpdatePage({super.key, required this.fillingData});
//
//   @override
//   State<FillingRequestUpdatePage> createState() =>
//       _FillingRequestUpdatePageState();
// }
//
// class _FillingRequestUpdatePageState extends State<FillingRequestUpdatePage> {
//   final TextEditingController remarksController = TextEditingController();
//   final TextEditingController actualQtyController = TextEditingController();
//
//   String selectedStatus = "Completed";
//   bool isSubmitting = false;
//
//   final ImagePicker _picker = ImagePicker();
//
//   Map<String, XFile?> selectedImages = {
//     "Document 1": null,
//     "Document 2": null,
//     "Document 3": null,
//   };
//
//   Future<void> _pickImage(String label) async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//
//     if (image != null) {
//       setState(() {
//         selectedImages[label] = image;
//       });
//     }
//   }
//
//   Future<void> submitFillingUpdate(BuildContext context) async {
//     setState(() => isSubmitting = true);
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final staffId = prefs.getString('staff_id') ?? '';
//       final role = prefs.getString('role') ?? '';
//
//       final uri = Uri.parse("${ApiConstants.baseUrl}/update_req_status");
//       var request = http.MultipartRequest('POST', uri);
//
//       request.fields['staff_id'] = staffId;
//       request.fields['role'] = role;
//       request.fields['request_id'] = widget.fillingData['id'].toString();
//
//       final actualQty = actualQtyController.text.trim().isEmpty
//           ? widget.fillingData['qty'].toString()
//           : actualQtyController.text.trim();
//       request.fields['aqty'] = actualQty;
//       request.fields['status'] = selectedStatus;
//       request.fields['remarks'] = remarksController.text;
//
//       for (int i = 1; i <= 3; i++) {
//         final XFile? file = selectedImages["Document $i"];
//         if (file != null && file.path.isNotEmpty) {
//           request.files.add(await http.MultipartFile.fromPath(
//             'doc$i',
//             file.path,
//           ));
//         }
//       }
//
//       var response = await request.send();
//       final respStr = await response.stream.bytesToString();
//       final decodedResp = jsonDecode(respStr);
//
//       setState(() => isSubmitting = false);
//
//       if (response.statusCode == 200 && decodedResp['status'] == 200) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Success'),
//             content: Text(decodedResp['data']?['msgs'] ??
//                 'Status updated successfully'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context); // dialog
//                   Navigator.pop(context); // page
//                   Navigator.pop(context); // previous page
//                   Navigator.pop(context); // go back to dashboard
//                 },
//                 style: TextButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       } else {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Error'),
//             content: Text(
//                 decodedResp['data']?['msg'] ?? "Something went wrong"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: TextButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => isSubmitting = false);
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Exception'),
//           content: Text('Something went wrong: $e'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   /////////////////////////////////////////////////////
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Request Filling Update"),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: const BackButton(),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         buildGroupedDataCard(),
//                         const SizedBox(height: 12),
//
//                         /// Camera fields
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             buildFileBox("Document 1"),
//                             buildFileBox("Document 2"),
//                             buildFileBox("Document 3"),
//                           ],
//                         ),
//
//                         const SizedBox(height: 12),
//                         buildDropdownRow("Status", selectedStatus),
//                         buildInputRow("Remarks", remarksController,
//                             maxLines: 1, hint: "Enter Remarks"),
//                         buildInputRow("Actual Quantity", actualQtyController,
//                             hint: "Enter Actual Quantity"),
//                         const SizedBox(height: 16),
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             "Note: Recheck details for particular vehicle number",
//                             style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black87),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: 160,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: () => submitFillingUpdate(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF13688B),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8)),
//                     ),
//                     child: const Text("Submit",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isSubmitting)
//             Container(
//               color: Colors.black.withOpacity(0.4),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     SpinKitThreeBounce(
//                       color: Colors.orange,
//                       size: 40.0,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       "Processing...",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.orange,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildGroupedDataCard() {
//     final data = widget.fillingData;
//     if (actualQtyController.text.isEmpty) {
//       actualQtyController.text = data['qty']?.toString() ?? '';
//     }
//
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade400),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           infoRow("RID", data['rid']),
//           infoRow("Product Name", data['product_name']),
//           infoRow("Vehicle Number", data['vehicle_number']),
//           infoRow("Station Name", data['station_name']),
//           infoRow("Customer Name", data['customer_name']),
//           infoRow("Customer Phone", data['customer_phone']),
//           infoRow("Driver Number", data['driver_number']),
//           infoRow("Date & Time", data['created']),
//           infoRow("Remark", data['rtype']),
//           infoRow("Status", data['status'], valueColor: Colors.orange),
//           infoRow("Quantity", data['qty']),
//         ],
//       ),
//     );
//   }
//
//   Widget infoRow(String label, dynamic value,
//       {bool isLast = false, Color? valueColor}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         border: isLast
//             ? null
//             : const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//               flex: 3,
//               child: Text(label,
//                   style:
//                   const TextStyle(fontWeight: FontWeight.w600))),
//           Container(
//             height: 20,
//             width: 1,
//             color: Colors.grey.shade400,
//             margin: const EdgeInsets.symmetric(horizontal: 8),
//           ),
//           Expanded(
//               flex: 5,
//               child: Text(value?.toString() ?? "-",
//                   style: TextStyle(
//                       fontSize: 14,
//                       color: valueColor ?? Colors.black))),
//         ],
//       ),
//     );
//   }
//
//   /// Camera Box Widget
//   Widget buildFileBox(String label) {
//     final XFile? image = selectedImages[label];
//
//     return InkWell(
//       onTap: () => _pickImage(label),
//       child: Container(
//         width: 80,
//         height: 80,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: image == null
//             ? const Icon(Icons.camera_alt,
//             color: Colors.blueGrey, size: 40)
//             : ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.file(
//             File(image.path),
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildDropdownRow(String label, String selectedValue) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Expanded(
//               flex: 4,
//               child: Text(label,
//                   style: const TextStyle(fontWeight: FontWeight.w500))),
//           const SizedBox(width: 10),
//           Expanded(
//             flex: 6,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade400),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: selectedValue,
//                   isExpanded: true,
//                   items: const [
//                     DropdownMenuItem(
//                         value: "Cancelled", child: Text("Cancelled")),
//                     DropdownMenuItem(
//                         value: "Completed", child: Text("Completed")),
//                   ],
//                   onChanged: (val) {
//                     if (val != null) {
//                       setState(() => selectedStatus = val);
//                     }
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildInputRow(String label, TextEditingController controller,
//       {int maxLines = 1, String? hint}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: maxLines > 1
//             ? CrossAxisAlignment.start
//             : CrossAxisAlignment.center,
//         children: [
//           Expanded(
//               flex: 4,
//               child: Text(label,
//                   style: const TextStyle(fontWeight: FontWeight.w500))),
//           const SizedBox(width: 10),
//           Expanded(
//             flex: 6,
//             child: TextFormField(
//               controller: controller,
//               maxLines: maxLines,
//               decoration: InputDecoration(
//                 hintText: hint,
//                 contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 10),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                   borderSide:
//                   BorderSide(color: Colors.grey.shade400),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
