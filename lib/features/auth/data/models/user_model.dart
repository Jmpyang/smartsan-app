// features/auth/data/models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // e.g., 'Worker', 'Admin', 'Community'

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  // Factory constructor to create a UserModel from Firebase data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }

  // Method to convert the model back to a map for database updates
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}