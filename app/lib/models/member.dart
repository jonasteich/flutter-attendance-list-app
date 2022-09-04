class Member {
  String name;
  bool isPresent;

  Member({
    required this.name,
    this.isPresent = false,
  });

  static List<Member> memberList() {
    return [
      Member(name: 'Max Mustermann'),
      Member(name: 'Doris Mustermann', isPresent: true),
      Member(name: 'Hans Mustermann'),
      Member(name: 'Peter Mustermann', isPresent: true),
      Member(name: 'Klaus Mustermann'),
    ];
  }
}
