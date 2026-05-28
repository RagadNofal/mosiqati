import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, customer }

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final UserRole role;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone   = '',
    this.address = '',
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid:      doc.id,
      name:     data['name']    as String? ?? '',
      email:    data['email']   as String? ?? '',
      phone:    data['phone']   as String? ?? '',
      address:  data['address'] as String? ?? '',
      role: (data['role'] as String?) == 'admin'
          ? UserRole.admin
          : UserRole.customer,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? address,
  }) => AppUser(
    uid:       uid,
    name:      name    ?? this.name,
    email:     email,
    phone:     phone   ?? this.phone,
    address:   address ?? this.address,
    role:      role,
    createdAt: createdAt,
  );

  Map<String, dynamic> toFirestore() => {
        'name':      name,
        'email':     email,
        'phone':     phone,
        'address':   address,
        'role':      role == UserRole.admin ? 'admin' : 'customer',
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
