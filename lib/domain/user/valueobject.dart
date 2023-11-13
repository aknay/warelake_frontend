import 'package:inventory_frontend/domain/role/entities.dart';

class User {
  String id; 
  Role role;
  String teamId; 
  String name;
  String email;
  String status;
  bool isCurrentUser;
  String photoUrl;
  bool isTeamOwner;

  User({
    required this.id,
    required this.role,
    required this.teamId,
    required this.name,
    required this.email,
    required this.status,
    required this.isCurrentUser,
    required this.photoUrl,
    required this.isTeamOwner,
  });

  // Factory method to create User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      role: Role.fromJson(json['role']),
      teamId: json['team_id'],
      name: json['name'],
      email: json['email'],
      status: json['status'],
      isCurrentUser: json['is_current_user'],
      photoUrl: json['photo_url'],
      isTeamOwner: json['is_team_owner'],
    );
  }

  // Method to convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toJson(),
      'team_id': teamId,
      'name': name,
      'email': email,
      'status': status,
      'is_current_user': isCurrentUser,
      'photo_url': photoUrl,
      'is_team_owner': isTeamOwner,
    };
  }
}