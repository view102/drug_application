class Drug {
  String typeOfAlarm;
  String drugId;
  String uid;
  String drugName;
  List<dynamic> times;
  List<dynamic> acts;
  String createDate;
  List<dynamic> manualTimes;

  Drug(
      {required this.typeOfAlarm,
      required this.drugId,
      required this.uid,
      required this.drugName,
      required this.times,
      required this.acts,
      required this.createDate,
      required this.manualTimes});

  // ส่วนของ name constructor ที่จะแปลง json string มาเป็น Article object
  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
        typeOfAlarm: json['typeOfAlarm'],
        drugId: json['drugId'],
        uid: json['uid'],
        drugName: json['drugName'],
        times: json['times'],
        acts: json['acts'],
        createDate: json['createDate'],
        manualTimes: json['manualTimes']);
  }
}
