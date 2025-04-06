class File {
  final String id;
  final String name;
  final String url;
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
      required this.locked,
      required this.filePassword,
      required this.description,
      required this.size});
}
