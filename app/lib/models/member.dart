class Member {
  String name;
  bool isPresent;
  String key;

  Member({
    required this.name,
    required this.key,
    this.isPresent = false,
  });
}
