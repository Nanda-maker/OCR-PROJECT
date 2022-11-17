import 'dart:ffi';

class Transaction {
  final int id;
  final String bank;
  final String refrenceNumber;
  final String rrno;
  final double amount;
  final String fromAC;
  final String toAC;
  final String date;
  final String time;
  final String remark;




  const Transaction({
    required this.id,
    required this.bank,
    required this.refrenceNumber,
    required this.rrno,
    required this.amount,
    required this.fromAC,
    required this.toAC,
    required this.date,
    required this.time,
    required this.remark
  });

  Transaction copy({
    int? id,
    String? bank,
    String? refrenceNumber,
    String? rrno,
    double? amount,
    String? fromAC,
    String? toAC,
    String? date,
    String? time,
    String? remark
  }) =>
      Transaction(
        id: id ?? this.id,
        bank: bank ?? this.bank,
        refrenceNumber: refrenceNumber ?? this.refrenceNumber,
        rrno: rrno ?? this.rrno,
        amount: amount ?? this.amount,
        fromAC: fromAC ?? this.fromAC,
        toAC: toAC ?? this.toAC,
        date: date ?? this.date,
        time: time ?? this.time,
        remark: remark ?? this.remark
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bank == other.bank &&
          refrenceNumber == other.refrenceNumber &&
          rrno == other.rrno &&
          amount == other.amount &&
          fromAC == other.fromAC &&
          toAC == other.toAC &&
          date == other.date &&
          time == other.time &&
          remark == other.remark;

  @override
  int get hashCode => bank.hashCode ^ refrenceNumber.hashCode ^ amount.hashCode;
}
