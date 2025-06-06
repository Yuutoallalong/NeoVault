import 'package:cloud_firestore/cloud_firestore.dart';

class FileInfo {
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
  final String userId;
  final String hash;

  FileInfo(
      {required this.id,
      required this.name,
      required this.url,
      required this.expiredIn,
      required this.createAt,
      required this.daysLeft,
      required this.locked,
      required this.filePassword,
      required this.description,
      required this.size,
      required this.userId,
      required this.hash});

  factory FileInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FileInfo(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      url: data['url'] ?? '',
      createAt: (data['createAt'] as Timestamp).toDate(),
      daysLeft: data['daysLeft'] ?? 7,
      expiredIn: (data['expiredIn'] as Timestamp).toDate(),
      locked: data['locked'] ?? false,
      filePassword: data['filePassword'] ?? '',
      description: data['description'] ?? '',
      size: data['size'] ?? 0.0,
      userId: data['userId'] ?? '',
      hash: data['hash'] ?? '',
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
      'userId': userId,
      'hash': hash
    };
  }
}
