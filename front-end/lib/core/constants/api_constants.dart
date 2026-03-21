import 'package:flutter/foundation.dart';

class ApiConstants {
  // Uses 127.0.0.1 on web (Chrome) and 10.0.2.2 on Android Emulator automatically.
  static const String baseUrl = kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://10.0.2.2:8000/api';

  // Teams (public — used for register dropdown)
  static const String teams = '/teams';

  // Auth
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

  // Players
  static const String players = '/teams/{team_id}/players';
  static const String player = '/players/{id}';

  // Formations
  static const String formations = '/formations';
  static const String formation = '/formations/{id}';
  static const String formationCopy = '/formations/{id}/copy';
  static const String formationPosition = '/formations/{formation_id}/positions/{position_id}';

  // Training
  static const String trainingSessions = '/teams/{team_id}/training';
  static const String trainingSession = '/training/{id}';
  static const String trainingAttendance = '/training/{id}/attendance';
  static const String trainingAttendanceItem = '/training/{id}/attendance/{player_id}';
}
