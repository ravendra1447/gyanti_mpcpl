class ApiConstants {
  // ✅ Base URL for your backend
  //static const String baseUrl = "http://10.0.2.2:5000"; // use 10.0.2.2 for Android emulator
   //static const String baseUrl = "http://192.168.31.54:9000";
   static const String baseUrl = "http://72.60.201.194:9000";// Use your PC IP for real device
  // static const String baseUrl = "https://masafipetro.com/new/api"; // Production URL

  // 🔹 Endpoints
  static const String login = "$baseUrl/api/login";
  static const String profile = "$baseUrl/api/profile";

  static const String fillingReqList = "$baseUrl/api/filling_req_list";
  static const String freqOtpCheck = "$baseUrl/api/freq_otp_check";
  static const String freqOtpGenerate = "$baseUrl/api/freq_otp_check/generate-otp";
  static const String updateReqStatus = "$baseUrl/api/update_req_status";
  static const String versionCheck = "$baseUrl/api/version_check";

// 🔹 Add more endpoints here as needed
// static const String register = "$baseUrl/api/register";
// static const String updateProfile = "$baseUrl/api/updateProfile";
}

