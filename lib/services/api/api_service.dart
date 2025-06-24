import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:frontend/services/auth/firebase_auth_methods.dart';
import 'package:provider/provider.dart';

class ApiService {
  // For Android Emulator
  // Will be API gateway in production
  static const String baseUrl = '';
  // For iOS Simulator
  // static const String baseUrl = 'http://localhost:8080/api';
  // For physical device (replace with your computer's IP address)
  // static const String baseUrl = 'http://192.168.1.xxx:8080/api';
  
  static const Duration _timeout = Duration(seconds: 10);
  
  final http.Client _client;
  final FirebaseAuthMethods _authMethods;

  ApiService(this._client, this._authMethods);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authMethods.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('ApiService: Making GET request to: $url');
      
      final headers = await _getHeaders();
      debugPrint('ApiService: Headers: $headers');
      
      final response = await _client.get(url, headers: headers)
          .timeout(_timeout, onTimeout: () {
        throw ApiException('Request timed out. Please check your internet connection or try again later.');
      });
      
      debugPrint('ApiService: Response status: ${response.statusCode}');
      debugPrint('ApiService: Response body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('ApiService: GET request failed: $e');
      if (e is ApiException) rethrow;
      throw ApiException(_getErrorMessage(e));
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      var url = Uri.parse('$baseUrl$endpoint');
      
      debugPrint('ApiService: Request data:');
      debugPrint(JsonEncoder.withIndent('  ').convert(data));
      
      final headers = await _getHeaders();
      debugPrint('ApiService: Headers:');
      debugPrint(JsonEncoder.withIndent('  ').convert(headers));
      
      if(endpoint == 'https://7b9e-197-55-251-232.ngrok-free.app/api/driver-offers') {
        url = Uri.parse('https://7b9e-197-55-251-232.ngrok-free.app/api/driver-offers');
        debugPrint('ApiService: Request data:');
        debugPrint(JsonEncoder.withIndent('  ').convert(data));
      }

      if(endpoint == 'https://7b9e-197-55-251-232.ngrok-free.app/api/rider-requests') {
        url = Uri.parse('https://7b9e-197-55-251-232.ngrok-free.app/api/rider-requests');
        debugPrint('ApiService: Request data:');
        debugPrint(JsonEncoder.withIndent('  ').convert(data));
      }

      debugPrint('----------ApiService: Making POST request to: $url');
      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(_timeout, onTimeout: () {
        throw ApiException('Request timed out. Please check your internet connection or try again later.');
      });
      
      debugPrint('ApiService: Response status: ${response.statusCode}');
      debugPrint('ApiService: Response body:');
      debugPrint(JsonEncoder.withIndent('  ').convert(jsonDecode(response.body)));
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('ApiService: POST request failed: $e');
      if (e is ApiException) rethrow;
      throw ApiException(_getErrorMessage(e));
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('ApiService: Making PUT request to: $url');
      debugPrint('ApiService: Request data: $data');
      
      final headers = await _getHeaders();
      debugPrint('ApiService: Headers: $headers');
      
      final response = await _client.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(_timeout, onTimeout: () {
        throw ApiException('Request timed out. Please check your internet connection or try again later.');
      });
      
      debugPrint('ApiService: Response status: ${response.statusCode}');
      debugPrint('ApiService: Response body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('ApiService: PUT request failed: $e');
      if (e is ApiException) rethrow;
      throw ApiException(_getErrorMessage(e));
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('ApiService: Making DELETE request to: $url');
      
      final headers = await _getHeaders();
      debugPrint('ApiService: Headers: $headers');
      
      final response = await _client.delete(url, headers: headers)
          .timeout(_timeout, onTimeout: () {
        throw ApiException('Request timed out. Please check your internet connection or try again later.');
      });
      
      debugPrint('ApiService: Response status: ${response.statusCode}');
      debugPrint('ApiService: Response body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('ApiService: DELETE request failed: $e');
      if (e is ApiException) rethrow;
      throw ApiException(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Unable to connect to the server. Please check your internet connection or try again later.';
    } else if (error.toString().contains('HandshakeException')) {
      return 'Unable to establish a secure connection. Please try again later.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please check your internet connection or try again later.';
    }
    return 'An unexpected error occurred. Please try again later.';
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw ApiException('The requested resource was not found.');
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized. Please log in again.');
    } else if (response.statusCode == 403) {
      throw ApiException('You do not have permission to access this resource.');
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error. Please try again later.');
    } else {
      throw ApiException(
        'Request failed with status: ${response.statusCode}. ${response.body}',
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
} 