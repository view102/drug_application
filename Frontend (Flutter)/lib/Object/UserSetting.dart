class UserSetting {
  String uid;
  String morning;
  String noon;
  String evening;
  String sleep;

  UserSetting(
      {required this.uid,
      required this.morning,
      required this.noon,
      required this.evening,
      required this.sleep});

  factory UserSetting.fromJson(Map<String, dynamic> json) {
    return UserSetting(
        uid: json['uid'],
        morning: json['morning'],
        noon: json['noon'],
        evening: json['evening'],
        sleep: json['sleep']);
  }
}
