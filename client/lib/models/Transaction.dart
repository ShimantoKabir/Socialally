class Transaction {
  int id;
  double creditAmount;
  double debitAmount;
  double amount;
  int accountHolderId;
  int ledgerId;
  String ledgerName;
  String transactionId;
  String accountNumber;
  String paymentGatewayName;
  String createdAt;
  String status;

  Transaction({
    this.id,
    this.creditAmount,
    this.debitAmount,
    this.amount,
    this.accountHolderId,
    this.ledgerId,
    this.ledgerName,
    this.transactionId,
    this.accountNumber,
    this.paymentGatewayName,
    this.createdAt,
    this.status
  });
}
