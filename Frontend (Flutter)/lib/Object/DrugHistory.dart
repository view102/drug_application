class DrugHistory {
  String uid;
  String drugName;
  String lastDate;

  DrugHistory(
      {required this.uid, required this.drugName, required this.lastDate});

  // ส่วนของ name constructor ที่จะแปลง json string มาเป็น Article object
  factory DrugHistory.fromJson(Map<String, dynamic> json) {
    return DrugHistory(
        uid: json['uid'],
        drugName: json['drugName'],
        lastDate: json['lastDate']);
  }
}
