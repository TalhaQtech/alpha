class Notifications {
  String senderId,
      senderName,
      receiverId,
      receiverName,
      title,
      description,
      date,
      time;

      bool read;

  Notifications(this.senderId, this.senderName, this.receiverId,
      this.receiverName, this.title, this.description, this.date, this.time,this.read);
}
