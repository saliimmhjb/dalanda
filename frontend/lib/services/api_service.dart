import 'dart:convert';
import 'package:dalanda/models/employee.dart';
import 'package:dalanda/models/leave_request.dart';
import 'package:dalanda/models/meeting.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = (data['token'] ?? '').toString().trim();
      if (token.isEmpty) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('role', (data['role'] ?? '').toString());
      await prefs.setString('username', (data['username'] ?? '').toString());
      await prefs.setString('email', (data['email'] ?? '').toString());
      String imageUrl = (data['image'] ?? '').toString();
      await prefs.setString('user_image', imageUrl.replaceAll('127.0.0.1', '10.0.2.2'));
      return true;
    }
    return false;
  }

  static Future<bool> register(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  static Future<String?> _authToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim();
    return token == null || token.isEmpty ? null : token;
  }

  static Future<Map<String, String>> _authHeaders() async {
    final headers = <String, String>{};
    final token = await _authToken();
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    return headers;
  }

  static Future<Map<String, String>> _jsonHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = await _authToken();
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    return headers;
  }

  // 🔥 NEW: Fetch Departments for Dropdowns
  static Future<List<dynamic>> getDepartments() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/departments/'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<List<dynamic>> getEmployees() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/employees/'),
      headers: headers,
    );
    try {
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // If department fields are numeric IDs, fetch departments and map ids -> names
        bool needsDeptLookup = data.any((e) => e != null && e['department'] != null && (e['department'] is int));
        Map<int, String> deptMap = {};
        if (needsDeptLookup) {
          final depts = await getDepartments();
          for (var d in depts) {
            try {
              final id = d['id'] as int;
              final name = d['name']?.toString() ?? '';
              deptMap[id] = name;
            } catch (_) {}
          }
        }

        if (deptMap.isNotEmpty) {
          for (var e in data) {
            if (e != null && e['department'] != null && (e['department'] is int)) {
              final id = e['department'] as int;
              e['department'] = {'id': id, 'name': deptMap[id] ?? id.toString()};
            }
          }
        }

        return data;
      } else {
        print('getEmployees failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('getEmployees error: $e');
    }
    return [];
  }

  // 🔥 UPDATED: Add Employee with Grade and Dept ID
  static Future<bool> addEmployeeWithImage(Map<String, String> data, File? imageFile) async {
    final token = await _authToken();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/employees/'));
    if (token != null) {
      request.headers['Authorization'] = 'Token $token';
    }
    request.fields.addAll(data);
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    var response = await request.send();
    return response.statusCode == 201;
  }

  static Future<List<Meeting>> getMeetings() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/meetings/'), headers: headers);
    try {
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((m) => Meeting.fromJson(m)).toList();
      } else {
        print('getMeetings failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('getMeetings error: $e');
    }
    return [];
  }

  static Future<bool> addMeeting(Map<String, dynamic> data) async {
    final headers = await _jsonHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/meetings/'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) return true;
    print('addMeeting failed: ${response.statusCode} ${response.body}');
    return false;
  }

  static Future<List<LeaveRequest>> getLeaves() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/leaves/'), headers: headers);
    try {
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((l) => LeaveRequest.fromJson(l)).toList();
      } else {
        print('getLeaves failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('getLeaves error: $e');
    }
    return [];
  }

  static Future<bool> addLeave(Map<String, dynamic> data) async {
    final headers = await _jsonHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/leaves/'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) return true;
    print('addLeave failed: ${response.statusCode} ${response.body}');
    return false;
  }

  static Future<String> getAiResponse(String message) async {
    final headers = await _jsonHeaders();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat/'),
        headers: headers,
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) return jsonDecode(response.body)['reply'];
      return "Error: Django server had a problem.";
    } catch (e) {
      return "Connection error. Make sure Ollama and Django are running.";
    }
  }

  static Future<bool> updateEmployee(int id, Map<String, dynamic> data, File? imageFile) async {
    final token = await _authToken();
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/employees/$id/'));
    if (token != null) {
      request.headers['Authorization'] = 'Token $token';
    }
    data.forEach((key, value) => request.fields[key] = value.toString());
    if (imageFile != null) request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    var response = await request.send();
    return response.statusCode == 200;
  }

  static Future<Employee?> getEmployeeById(int id) async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/employees/$id/'), headers: headers);
    if (response.statusCode == 200) return Employee.fromJson(jsonDecode(response.body));
    return null;
  }

  static Future<Employee?> getMyProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final myEmail = prefs.getString('email');
    List<dynamic> all = await getEmployees();
    try {
      final myData = all.firstWhere((emp) => emp['email'] == myEmail);
      return Employee.fromJson(myData);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateMeetingStatus(int id, String status) async {
    final headers = await _jsonHeaders();
    final response = await http.patch(Uri.parse('$baseUrl/meetings/$id/status/'), headers: headers, body: jsonEncode({'status': status}));
    return response.statusCode == 200;
  }

  static Future<bool> updateLeaveStatus(int id, String status) async {
    final headers = await _jsonHeaders();
    final response = await http.patch(Uri.parse('$baseUrl/leaves/$id/status/'), headers: headers, body: jsonEncode({'status': status}));
    return response.statusCode == 200;
  }
}