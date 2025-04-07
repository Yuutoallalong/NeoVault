class User {
  final String id;
  final String username;
  final String email;
  final int fileCount;
  final int expiredFileCount;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fileCount,
    required this.expiredFileCount,
  });
}
