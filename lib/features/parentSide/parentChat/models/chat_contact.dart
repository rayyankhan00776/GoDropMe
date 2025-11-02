class ParentChatContact {
  final String id;
  final String name;
  final String? avatarUrl;

  const ParentChatContact({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  static List<ParentChatContact> demo() => const [
    ParentChatContact(id: 'd1', name: 'Ali Raza', avatarUrl: null),
  ];
}
