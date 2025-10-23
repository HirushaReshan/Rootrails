class AppUser {
  final String uid;
  final String name;
  final String email;
  final List<String> pastBookings;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.pastBookings,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      pastBookings: List<String>.from(data['pastBookings'] ?? []),
    );
  }
}
