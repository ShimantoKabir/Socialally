class Transaction {
  int id;
  int depositAmount;
  int withdrawAmount;
  int accountHolderId;
  String transactionType;
  String transactionId;
  String accountNumber;
  String paymentGatewayName;
  String createdAt;
  String status;

  Transaction({
    this.id,
    this.depositAmount,
    this.withdrawAmount,
    this.accountHolderId,
    this.transactionType,
    this.transactionId,
    this.accountNumber,
    this.paymentGatewayName,
    this.createdAt,
    this.status
  });
}
