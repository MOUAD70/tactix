class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token, 
    this.teamId,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? token; 
  final int? teamId;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      token: json['token'] as String?,
      teamId: json['team_id'] is int ? json['team_id'] as int : (json['team_id'] is String ? int.tryParse(json['team_id'] as String) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
      'team_id': teamId,
    };
  }
}