import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../api_constants.dart';

class DashboardProvider with ChangeNotifier {
  List<Map<String, dynamic>> _permissions = [];

  List<Map<String, dynamic>> get permissions => _permissions;

  Future<void> fetchDashboardData(String staffId, String role) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/dashboard'),
        body: {
          'staff_id': staffId,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 200) {
          _permissions = List<Map<String, dynamic>>.from(jsonData['data']['permissions']);

          // Check if "Station Details" permission exists
          int stationIndex = _permissions.indexWhere((item) => item['title'] == 'Station Details');
          if (stationIndex != -1) {
            // Fetch station count
            int stationCount = await fetchStationCount(staffId);
            // Update count in permissions
            _permissions[stationIndex]['count'] = stationCount;
          } else {
            // Optionally add Station Details permission if not present
            _permissions.add({'title': 'Station Details', 'count': 0});
          }

          notifyListeners();
        } else {
          print("API error: ${jsonData['msg']}");
          _permissions = [];
          notifyListeners();
        }
      } else {
        print("HTTP error: ${response.statusCode}");
        _permissions = [];
        notifyListeners();
      }
    } catch (e) {
      print("Exception: $e");
      _permissions = [];
      notifyListeners();
    }
  }

  Future<int> fetchStationCount(String userId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/staff_station?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 200) {
          final stations = List<Map<String, dynamic>>.from(jsonData['stations'] ?? []);
          return stations.length;
        } else {
          print("Station API error: ${jsonData['message']}");
          return 0;
        }
      } else {
        print("Station HTTP error: ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("Station fetch exception: $e");
      return 0;
    }
  }
}
