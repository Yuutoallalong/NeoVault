class MyUser {
  final String id;
  final String username;
  final String email;
  final int fileCount;
  final int expiredFileCount;

  MyUser({
    required this.id,
    required this.username,
    required this.email,
    required this.fileCount,
    required this.expiredFileCount,
  });
  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fileCount: json['fileCount'],
      expiredFileCount: json['expiredFileCount'],
    );
  }
}
