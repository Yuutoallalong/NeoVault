import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class File {
  final String id;
  final String name;
  final String url;
  final DateTime createAt;
  final int daysLeft;
  final DateTime expiredIn;
  final bool locked;
  final String filePassword;
  final String description;
  final double size;

  File(
      {required this.id,
      required this.name,
      required this.url,
      required this.expiredIn,
      required this.createAt,
      required this.daysLeft,
      required this.locked,
      required this.filePassword,
      required this.description,
      required this.size});

  factory File.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return File(
      id: doc.id,
      name: data['name'] ?? '',
      url: data['url'] ?? '',
      createAt: (data['createAt'] as Timestamp).toDate(),
      daysLeft: data['daysLeft'] ?? 0,
      expiredIn: (data['expiredIn'] as Timestamp).toDate(),
      locked: data['locked'] ?? false,
      filePassword: data['filePassword'] ?? '',
      description: data['description'] ?? '',
      size: data['size'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'createAt': createAt,
      'daysLeft': daysLeft,
      'expiredIn': expiredIn,
      'locked': locked,
      'filePassword': filePassword,
      'description': description,
      'size': size,
    };
  }
}
