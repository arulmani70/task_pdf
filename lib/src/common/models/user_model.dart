import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String roleId;
  final String phone;
  final String createdAt;

  const UsersModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    required this.phone,
    required this.createdAt,
  });

  UsersModel copyWith({
    String? id,
    String? name,
    String? email,
    String? roleId,
    String? phone,
    String? createdAt,
  }) {
    return UsersModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['roleId'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  factory UsersModel.empty() {
    return const UsersModel(
      id: '',
      name: '',
      email: '',
      roleId: '',
      phone: '',
      createdAt: '',
    );
  }

  // New factory to create from Firebase User
  factory UsersModel.fromFirebaseUser(User user) {
    return UsersModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      roleId:
          '', // Role info probably not from Firebase, leave empty or fetch separately
      phone: user.phoneNumber ?? '',
      createdAt: '', // Firebase User does not have createdAt directly
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "roleId": roleId,
    "phone": phone,
    "createdAt": createdAt,
  };

  @override
  List<Object?> get props => [id, name, email, roleId, phone, createdAt];
}
