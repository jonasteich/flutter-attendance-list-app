class GroupArgs {
  final String groupKey;
  final String groupName;
  final String? meetingKey;
  final String? meetingName;

  GroupArgs({
    required this.groupKey,
    required this.groupName,
    this.meetingKey,
    this.meetingName,
  });
}
