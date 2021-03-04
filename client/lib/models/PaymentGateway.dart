class PaymentGateway{
  int id;
  String paymentGatewayName;
  String cashInNumber;
  String personalNumber;
  String agentNumber;

  PaymentGateway({
    this.id,
    this.paymentGatewayName,
    this.personalNumber,
    this.agentNumber,
    this.cashInNumber
  });
}