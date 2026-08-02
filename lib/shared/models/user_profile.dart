class UserProfile {
  final String name;
  final String email;
  final String avatar;
  final bool isSynced;

  UserProfile({required this.name, required this.email, this.avatar = '', this.isSynced = true});
}
