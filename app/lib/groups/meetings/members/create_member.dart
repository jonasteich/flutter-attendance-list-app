import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CreateMemberArgs {
  final String meetingKey;
  final String meetingName;
  final String groupName;
  final String groupKey;
  CreateMemberArgs(
      this.meetingKey, this.meetingName, this.groupName, this.groupKey);
}

class CreateMember extends StatefulWidget {
  const CreateMember({Key? key}) : super(key: key);

  static const routeName = '/group/meeting/member/create';

  @override
  State<CreateMember> createState() => _CreateMemberState();
}

class _CreateMemberState extends State<CreateMember> {
  final _database = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as CreateMemberArgs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            label: Text('Name'),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () {
            _database
                .child('groups')
                .child(user!.uid)
                .child(args.groupKey)
                .child('members')
                .push()
                .set({'name': nameController.text});
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ),
    );
  }
}
