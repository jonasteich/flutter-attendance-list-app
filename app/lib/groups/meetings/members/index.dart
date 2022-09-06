import 'package:app/groups/meetings/members/member_view.dart';
import 'package:app/models/group_args.dart';
import 'package:app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/member.dart';
import 'create_member.dart';

class MeetingPage extends StatelessWidget {
  const MeetingPage({Key? key}) : super(key: key);

  static String routeName = '/group/meeting';

  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase.instance.ref();
    final user = FirebaseAuth.instance.currentUser;
    final args = ModalRoute.of(context)!.settings.arguments as GroupArgs;
    String clipboardText = '';

    bool _handleIsPresentChange(Member member) {
      bool isPresent = !member.isPresent;
      if (isPresent) {
        database
            .child('groups')
            .child(user!.uid)
            .child(args.groupKey)
            .child('meetings')
            .child(args.meetingKey!)
            .child('present_members')
            .push()
            .set(member.name);
      } else {
        database
            .child('groups')
            .child(user!.uid)
            .child(args.groupKey)
            .child('meetings')
            .child(args.meetingKey!)
            .child('present_members')
            .orderByValue()
            .equalTo(member.name)
            .once()
            .then(
          (value) {
            Map data = (value.snapshot.value as Map);
            data.forEach(
              (key, value) {
                if (value == member.name) {
                  database
                      .child('groups')
                      .child(user.uid)
                      .child(args.groupKey)
                      .child('meetings')
                      .child(args.meetingKey!)
                      .child('present_members')
                      .child(key)
                      .remove();
                }
              },
            );
          },
        );
      }
      return isPresent;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(args.meetingName!),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: clipboardText),
              );
              Utils.showSuccessSnackBar('Copied to clipboard');
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: database
            .child('groups')
            .child(user!.uid)
            .child(args.groupKey)
            .child('meetings')
            .child(args.meetingKey!)
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
            stream: database
                .child('groups')
                .child(user.uid)
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
                        .contains(e.child('name').value as String),
                    key: e.key!,
                  );
                }).toList();

                String absentMember = memberList
                    .where((element) => !element.isPresent)
                    .map((e) => e.name.split(' ').first)
                    .join(', ');
                clipboardText =
                    '*${args.meetingName}*\nBesucher: ${presentMembers.length}\nAbwesend: $absentMember';

                return ListView(
                  children: [
                    for (var member in memberList)
                      MemberView(
                        member: member,
                        onMemberChange: _handleIsPresentChange,
                        groupKey: args.groupKey,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            CreateMember.routeName,
            arguments: CreateMemberArgs(
              args.meetingKey!,
              args.meetingName!,
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
