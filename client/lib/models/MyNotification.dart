class MyNotification{
  int id;
  String message;
  int receiverId;
  int senderId;
  int type;
  int isSeen;
  String senderName;
  String createdAt;

  MyNotification({
    this.id,
    this.message,
    this.receiverId,
    this.senderId,
    this.type,
    this.isSeen,
    this.senderName,
    this.createdAt
  });
}