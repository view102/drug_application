class DrugFda {
  String status;
  String brandName;
  String genericName;
  String indicationsAndUsage;

  DrugFda(
      {required this.status,
      required this.brandName,
      required this.genericName,
      required this.indicationsAndUsage});

  factory DrugFda.fromJson(Map<String, dynamic> json) {
    return new DrugFda(
        status: json['status'],
        brandName: json['brand_name'],
        genericName: json["generic_name"],
        indicationsAndUsage: json["indications_and_usage"]);
  }
}
