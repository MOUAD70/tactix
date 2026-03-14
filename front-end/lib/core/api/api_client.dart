import 'package:flutter_application_1/core/constants/app_constants.dart';

class ApiClient {
  const ApiClient({this.baseUrl = AppConstants.baseApiUrl});

  final String baseUrl;

  Uri buildUri(String path) => Uri.parse('$baseUrl$path');

  Future<void> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? teamId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> me() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}