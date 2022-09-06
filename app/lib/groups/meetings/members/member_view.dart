import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import '../../../models/member.dart';

class MemberView extends StatefulWidget {
  final Member member;
  final dynamic onMemberChange;
  final String groupKey;

  const MemberView({
    Key? key,
    required this.member,
    required this.onMemberChange,
    required this.groupKey,
  }) : super(key: key);

  @override
  State<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends State<MemberView> {
  final _database = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          widget.member.isPresent = widget.onMemberChange(widget.member);
        });
      },
      leading: widget.member.isPresent
          ? const Icon(
              Icons.check_box,
              color: Colors.green,
            )
          : const Icon(
              Icons.check_box_outline_blank,
              color: Colors.grey,
            ),
      trailing: FocusedMenuHolder(
        menuItems: [
          FocusedMenuItem(
            title: const Text('Delete'),
            trailingIcon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              _deleteMember(widget.member.key);
            },
          )
        ],
        openWithTap: true,
        blurBackgroundColor: Colors.grey,
        onPressed: () {},
        child: const Icon(Icons.more_vert),
      ),
      title: Text(widget.member.name),
    );
  }

  void _deleteMember(String key) {
    widget.member.isPresent = false;
    _database
        .child('groups')
        .child(user!.uid)
        .child(widget.groupKey)
        .child('members')
        .child(key)
        .remove();
  }
}
