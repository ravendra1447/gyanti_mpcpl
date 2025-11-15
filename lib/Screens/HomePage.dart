import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import 'my_details.dart';
import 'FillingRequestPage.dart';
import 'login_screen.dart';
import 'StationDetailsPage.dart';

class HomePage extends StatefulWidget {
  final Map userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List dashboardItems = [];
  bool isLoading = true;
  bool isApiLoading = false;
  int _currentIndex = 0;

  final Map<String, IconData> iconMap = {
    "My Details": Icons.person_outline,
    "Filling Requests": Icons.local_gas_station_outlined,
    "LR Management": Icons.assignment_outlined,
    "Vouchers": Icons.receipt_long_outlined,
    "Vehicles": Icons.local_shipping_outlined,
    "Station Details": Icons.business_outlined,
  };

  final Map<String, List<Color>> gradientMap = {
    "My Details": [Color(0xFF667eea), Color(0xFF764ba2)],
    "Filling Requests": [Color(0xFFf093fb), Color(0xFFf5576c)],
    "LR Management": [Color(0xFF4facfe), Color(0xFF00f2fe)],
    "Vouchers": [Color(0xFF43e97b), Color(0xFF38f9d7)],
    "Vehicles": [Color(0xFFfa709a), Color(0xFFfee140)],
    "Station Details": [Color(0xFFa8edea), Color(0xFFfed6e3)],
  };

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      print("🔄 Fetching dashboard data...");

      // TEMPORARY: Use hardcoded data since API returns 404
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        dashboardItems = [
          {'title': 'My Details', 'count': 5},
          {'title': 'Filling Requests', 'count': 12},
          {'title': 'LR Management', 'count': 8},
          {'title': 'Vouchers', 'count': 3},
          {'title': 'Vehicles', 'count': 15},
          {'title': 'Station Details', 'count': 1},
        ];
        isLoading = false;
      });

      print("✅ Using hardcoded dashboard data");

    } catch (e) {
      print("❌ Dashboard Error: $e");
      _useFallbackData();
    }
  }

  void _useFallbackData() {
    setState(() {
      dashboardItems = [
        {'title': 'My Details', 'count': 5},
        {'title': 'Filling Requests', 'count': 12},
        {'title': 'LR Management', 'count': 8},
        {'title': 'Vouchers', 'count': 3},
        {'title': 'Vehicles', 'count': 15},
        {'title': 'Station Details', 'count': 1},
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Color(0xFF13688B).withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: Color(0xFF13688B),
            size: 20,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, ${widget.userData['name']?.split(' ')[0] ?? 'User'}!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            "Welcome to MPCPL",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        _buildNotificationIcon(),
        _buildLogoutButton(),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
          onPressed: () => _showInfoDialog("Notifications", "No new notifications"),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: BoxConstraints(
              minWidth: 14,
              minHeight: 14,
            ),
            child: Text(
              '3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      icon: Icon(Icons.logout, color: Colors.grey[700]),
      onPressed: () {
        _showLogoutConfirmation();
      },
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingWidget();
    }

    return Stack(
      children: [
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildWelcomeCard(),
              SizedBox(height: 24),
              _buildQuickStats(),
              SizedBox(height: 24),
              _buildDashboardGrid(),
              SizedBox(height: 80),
            ],
          ),
        ),
        if (isApiLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF13688B)),
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            "Preparing your dashboard...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF13688B), Color(0xFF0D4E6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF13688B).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.userData['name'] ?? "User",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.userData['station_name'] ?? "MPCPL Station",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Ready to work",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              "Today's Tasks",
              "8",
              Icons.task_alt_outlined,
              Color(0xFF4CAF50),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              "Pending",
              "3",
              Icons.pending_actions_outlined,
              Color(0xFFFF9800),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              "Completed",
              "5",
              Icons.check_circle_outline,
              Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: dashboardItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final item = dashboardItems[index];
              final title = item['title']?.toString() ?? 'Unknown';
              final count = int.tryParse(item['count']?.toString() ?? '0') ?? 0;
              final icon = iconMap[title] ?? Icons.dashboard_outlined;
              final colors = gradientMap[title] ?? [Colors.grey, Colors.blueGrey];

              return _buildDashboardCard(title, count, icon, colors[0], colors[1]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, int count, IconData icon, Color startColor, Color endColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _handleCardTap(title),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: startColor.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showQuickActions();
      },
      backgroundColor: Color(0xFF13688B),
      elevation: 4,
      child: Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF13688B),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: SizedBox.shrink(),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF13688B)),
              ),
              SizedBox(height: 16),
              Text(
                "Loading...",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: [
                _buildQuickActionItem(Icons.add, "New Request"),
                _buildQuickActionItem(Icons.search, "Search"),
                _buildQuickActionItem(Icons.qr_code, "Scan QR"),
                _buildQuickActionItem(Icons.report, "Report"),
                _buildQuickActionItem(Icons.help, "Help"),
                _buildQuickActionItem(Icons.feedback, "Feedback"),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF13688B).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF13688B)),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF13688B),
            ),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _handleCardTap(String title) {
    print("Tapped: $title");

    if (title == "Filling Requests") {
      _showVehicleSearchDialog();
    } else if (title == "My Details") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Mydetails()),
      );
    } else if (title == "Station Details") {
      _fetchStationDetails();
    } else {
      _showFeatureDialog(title);
    }
  }

  void _showVehicleSearchDialog() {
    final TextEditingController vehicleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 48, color: Color(0xFF13688B)),
              SizedBox(height: 16),
              Text(
                'Search Vehicle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: vehicleController,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter Vehicle Number',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final vnum = vehicleController.text.trim();
                        if (vnum.length < 6) {
                          _showInfoDialog('Invalid Input', 'Please enter valid vehicle number (min 6 characters)');
                          return;
                        }
                        Navigator.pop(context);
                        await _fetchFillingRequests(vnum);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fetchStationDetails() {
    setState(() => isApiLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isApiLoading = false);

      final List<Map<String, dynamic>> stations = [
        {
          'name': 'Main Station',
          'address': '123 Main Street, City',
          'contact_number': '+91 9876543210',
        }
      ];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StationDetailsPage(stations: stations)),
      );
    });
  }

  Future<void> _fetchFillingRequests(String vehicleNumber) async {
    try {
      print("=== 🚀 FETCH FILLING REQUESTS STARTED ===");
      setState(() => isApiLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString('staff_id') ?? '';
      final role = prefs.getString('role') ?? '';

      print("📤 Request Details:");
      print("   URL: ${ApiConstants.fillingReqList}");
      print("   Staff ID: '$staffId'");
      print("   Role: '$role'");
      print("   Vehicle: '$vehicleNumber'");

      final uri = Uri.parse(ApiConstants.fillingReqList);
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'vehicle_number': vehicleNumber,
          'staff_id': staffId,
          'role': role,
        },
      ).timeout(Duration(seconds: 30));

      print("=== 📥 API RESPONSE ===");
      print("   Status Code: ${response.statusCode}");
      print("   Body Length: ${response.body.length}");

      // Print only first 500 characters to avoid too long logs
      final bodyPreview = response.body.length > 500
          ? "${response.body.substring(0, 500)}..."
          : response.body;
      print("   Body Preview: $bodyPreview");

      setState(() => isApiLoading = false);

      // 🎯 IMPROVED ERROR HANDLING
      if (response.statusCode == 500) {
        _handle500Error(response, vehicleNumber);
        return;
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        _showInfoDialog(
            'HTTP Error',
            'Failed to fetch requests\nStatus Code: ${response.statusCode}'
        );
        return;
      }

      // ✅ Safe JSON decoding
      if (response.body.isEmpty) {
        _showInfoDialog('Error', 'Empty response from server');
        return;
      }

      final decoded = json.decode(response.body);
      print("🔍 Decoded Response Type: ${decoded.runtimeType}");

      // ✅ Check API-level status
      final apiStatus = decoded['status'];
      if (apiStatus != 200) {
        final errorMsg = decoded['msg'] ?? 'Unknown API error';
        final errors = decoded['errors'] ?? {};

        String errorDetails = 'API Error: $errorMsg';
        if (errors.isNotEmpty) {
          errorDetails += '\n\nDetails: $errors';
        }

        _showInfoDialog('API Error', errorDetails);
        return;
      }

      // ✅ Extract data with better error handling
      List<Map<String, dynamic>> list = [];

      if (decoded['data'] != null) {
        final data = decoded['data'];
        print("📊 Data Type: ${data.runtimeType}");

        if (data is Map && data['filling_requests'] is List) {
          list = List<Map<String, dynamic>>.from(data['filling_requests']);
          print("✅ Found ${list.length} requests in data.filling_requests");
        }
        else if (data is List) {
          list = List<Map<String, dynamic>>.from(data);
          print("✅ Found ${list.length} requests in data list");
        }
        else if (data is Map) {
          // Try other possible keys
          final possibleKeys = ['requests', 'records', 'list', 'filling_requests'];
          for (final key in possibleKeys) {
            if (data[key] is List) {
              list = List<Map<String, dynamic>>.from(data[key]);
              print("✅ Found ${list.length} requests in data.$key");
              break;
            }
          }
        }
      }

      // ✅ If no data found, check for message
      if (list.isEmpty) {
        final apiMsg = decoded['msg'] ?? 'No filling requests found';
        _showInfoDialog('Information', '$apiMsg for vehicle $vehicleNumber');
        return;
      }

      // ✅ Add vehicle number if missing
      for (final m in list) {
        m['vehicle_number'] = m['vehicle_number'] ?? vehicleNumber;
      }

      print("🚀 Navigating to FillingRequestPage with ${list.length} requests");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FillingRequestPage(requestList: list),
        ),
      );

    } catch (e) {
      setState(() => isApiLoading = false);
      print("=== ❌ EXCEPTION ===");
      print("Error: $e");
      _showInfoDialog('Error', 'Exception occurred: $e');
    }
  }

  void _handle500Error(http.Response response, String vehicleNumber) {
    print("🎯 Handling 500 Error");

    // Show detailed error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Server Error 500"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Server returned 500 Internal Server Error",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("This is a SERVER-SIDE issue."),
              SizedBox(height: 10),
              Text("Possible causes:"),
              SizedBox(height: 5),
              Text("• API server is down"),
              Text("• Database connection failed"),
              Text("• Server code has errors"),
              SizedBox(height: 10),
              Text("Response from server:"),
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  response.body.isEmpty ? "Empty response" : response.body,
                  style: TextStyle(fontFamily: 'Monospace', fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Try with mock data as fallback
              _useMockData(vehicleNumber);
            },
            child: Text('Use Demo Data'),
          ),
        ],
      ),
    );
  }

  void _useMockData(String vehicleNumber) {
    print("🔄 Using mock data as fallback");

    final mockData = [
      {
        "id": 1,
        "vehicle_number": vehicleNumber,
        "status": "Pending",
        "station_name": "Demo Station",
        "customer_name": "Demo Customer",
        "product_name": "Demo Product",
        "qty": 100,
        "created": "2024-01-01",
      }
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FillingRequestPage(requestList: mockData),
      ),
    );
  }

  void _showFeatureDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 48, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Coming Soon',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '$title feature is under development',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF13688B),
                ),
                child: Text('Got It'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}