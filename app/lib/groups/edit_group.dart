import 'package:app/models/group_args.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EditGroup extends StatefulWidget {
  const EditGroup({Key? key}) : super(key: key);

  static String routeName = '/group/edit';

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  final _database = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GroupArgs;
    final nameController = TextEditingController(text: args.groupName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          autofocus: true,
          controller: nameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Name',
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
                .update({'name': nameController.text});
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ),
    );
  }
}
