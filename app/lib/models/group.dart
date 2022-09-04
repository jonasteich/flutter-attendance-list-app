import 'package:app/models/meeting.dart';
import 'package:app/models/member.dart';
import 'package:flutter/material.dart';

class Group {
  final String name;
  final List<Member> members;
  final List<Meeting> meetings;

  Group({required this.name, required this.members, required this.meetings});
}
