import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralUser {
  final String uid;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  // Fields for profile page
  final String profileImageUrl;
  final String phoneNumber;
  final String bio;

  GeneralUser({
    required this.uid,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.profileImageUrl = '',
    this.phoneNumber = '',
    this.bio = '',
  });

  // 👇 ADD THIS GETTER TO RESOLVE THE 'fullName' ERROR
  String get fullName {
    // Combines first name and last name, trimming any extra whitespace if one is empty
    return '$firstName $lastName'.trim();
  }

  factory GeneralUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("User data not available.");
    }
    return GeneralUser(
      uid: doc.id,
      userName: data['user_name'] ?? 'Guest',
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'general_user',
      profileImageUrl:
          data['profile_image_url'] ?? 'https://via.placeholder.com/150',
      phoneNumber: data['phone_number'] ?? '',
      bio: data['bio'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'user_name': userName,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': role,
      'profile_image_url': profileImageUrl,
      'phone_number': phoneNumber,
      'bio': bio,
    };
  }
}