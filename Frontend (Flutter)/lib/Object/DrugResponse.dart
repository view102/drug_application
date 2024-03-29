

import 'package:term_project/Object/Drug.dart';

class DrugResponse {
  final List<Drug> result;

  DrugResponse({
    required this.result,
  });

  // ส่วนของ name constructor ที่จะแปลง json string มาเป็น Article object
  factory DrugResponse.fromJson(Map<String, dynamic> json) {
    return DrugResponse(
        result: json['result']
    );
  }

}