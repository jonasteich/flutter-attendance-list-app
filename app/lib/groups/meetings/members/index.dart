import 'package:app/groups/meetings/members/member_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../models/member.dart';
import 'create_member.dart';

class MeetingPageArgs {
  final String meetingKey;
  final String meetingName;
  final String groupName;
  final String groupKey;
  MeetingPageArgs(
      this.meetingKey, this.meetingName, this.groupName, this.groupKey);
}

class MeetingPage extends StatelessWidget {
  const MeetingPage({Key? key}) : super(key: key);

  static String routeName = '/group/meeting';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as MeetingPageArgs;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.meetingName),
      ),
      body: MemberList(
        meetingKey: args.meetingKey,
        groupName: args.groupName,
        groupKey: args.groupKey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            CreateMember.routeName,
            arguments: CreateMemberArgs(
              args.meetingKey,
              args.meetingName,
              args.groupName,
              args.groupKey,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MemberList extends StatefulWidget {
  final String meetingKey;
  final String groupName;
  final String groupKey;

  const MemberList({
    Key? key,
    required this.meetingKey,
    required this.groupName,
    required this.groupKey,
  }) : super(key: key);

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  final _database = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as MeetingPageArgs;
    return FutureBuilder(
      future: _database
          .child('groups')
          .child(user!.uid)
          .child(args.groupKey)
          .child('meetings')
          .child(args.meetingKey)
          .once(),
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!.snapshot.hasChild('present_members')
            ? snapshot.data!.snapshot.child('present_members').value as Map
            : {};
        List<String> presentMembers = data.values.toList().cast<String>();

        return StreamBuilder(
          stream: _database
              .child('groups')
              .child(user!.uid)
              .child(args.groupKey)
              .child('members')
              .onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.hasData) {
              List<Member> memberList =
                  snapshot.data!.snapshot.children.toList().map((e) {
                return Member(
                    name: e.child('name').value as String,
                    isPresent: presentMembers
                        .contains(e.child('name').value as String));
              }).toList();

              return ListView(
                children: [
                  for (var member in memberList)
                    MemberView(
                      member: member,
                      onMemberChange: _handleIsPresentChange,
                    ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }

  bool _handleIsPresentChange(Member member) {
    bool isPresent = !member.isPresent;
    if (isPresent) {
      _database
          .child('groups')
          .child(user!.uid)
          .child(widget.groupKey)
          .child('meetings')
          .child(widget.meetingKey)
          .child('present_members')
          .push()
          .set(member.name);
    } else {
      _database
          .child('groups')
          .child(user!.uid)
          .child(widget.groupKey)
          .child('meetings')
          .child(widget.meetingKey)
          .child('present_members')
          .orderByValue()
          .equalTo(member.name)
          .once()
          .then((value) {
        Map data = (value.snapshot.value as Map);
        data.forEach((key, value) {
          if (value == member.name) {
            _database
                .child('groups')
                .child(user!.uid)
                .child(widget.groupKey)
                .child('meetings')
                .child(widget.meetingKey)
                .child('present_members')
                .child(key)
                .remove();
          }
        });
      });
    }
    return isPresent;
  }
}
