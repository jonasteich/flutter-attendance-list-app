import 'package:app/models/member.dart';

class Meeting {
  final String date;
  final List<Member> presentMembers;

  Meeting({required this.date, required this.presentMembers});
}
