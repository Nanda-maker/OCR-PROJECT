class TransactionDetail {
  String bankName;
  int amount;
  String referenceNo;
  String? fromAC;
  String? toAC;
  String date;
  String? remark;

  TransactionDetail({required this.bankName, required this.amount, required this.referenceNo, this.fromAC, this.toAC, required this.date, this.remark});

  Map<String,dynamic> toMap(){
    return {
      "bankName" : bankName,
      "amount" : amount,
      "referenceNo" : referenceNo,
      "fromAC" : fromAC,
      "toAC" : toAC,
      "date":date,
      "remark" : remark
    };
}
}
