class UserDetails {
  String userName;
  String userEmail;
  String userImage;
  String userUid;
  UserDetails({
    required this.userEmail,
    required this.userImage,
    required this.userName,
    required this.userUid,
  });

  String get getUserName => userName;
  String get getUserEmail => userEmail;
  String get getUserImage => userImage;
  String get getUserUid => userUid;
}
