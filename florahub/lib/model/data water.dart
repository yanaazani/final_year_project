import 'dart:ffi';

/**
 * This class is for waterr data from MySQL
 */

class DataWater {
  int id = 0;
  String date = "";
  double flowRate = 0.0;
  double volumn = 0.0;
  double amount = 0.0;

  DataWater({
    this.id = 0,
    this.date = "",
    this.flowRate = 0.0,
    this.volumn = 0.0,
    this.amount = 0.0,
  });

  factory DataWater.fromJson(Map<String, dynamic> json) {
    return DataWater(
      id: json['id'] ?? 0,
      date: json['date'] ?? "",
      flowRate: json['flowRate'] ?? 0.0,
      volumn: json['volumn'] ?? 0.0,
      amount: json['amount'] ?? 0.0,
    );
  }

  int get _Id => id;
  set _Id(int value) => id = value;

  String get _date => date;
  set _date(String value) => date = value;

  double get _flowRate => flowRate;
  set _flowRate(double value) => flowRate = value;

  double get _volumn => volumn;
  set _volumn(double value) => volumn = value;

  double get _amount => amount;
  set _amount(double value) => amount = value;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'flowRate': flowRate,
      'volumn': volumn,
      'amount': amount,
    };
  }
}
