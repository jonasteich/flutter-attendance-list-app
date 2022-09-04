import 'package:flutter/material.dart';

import '../../../models/member.dart';

class MemberView extends StatefulWidget {
  final Member member;
  final dynamic onMemberChange;

  const MemberView({
    Key? key,
    required this.member,
    required this.onMemberChange,
  }) : super(key: key);

  @override
  State<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends State<MemberView> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          widget.member.isPresent = widget.onMemberChange(widget.member);
        });
      },
      trailing: widget.member.isPresent
          ? const Icon(
              Icons.check_box,
              color: Colors.green,
            )
          : const Icon(
              Icons.check_box_outline_blank,
              color: Colors.grey,
            ),
      title: Text(widget.member.name),
    );
  }
}
