class Orders {
  String orderId,
      itemName,
      itemDesc,
      itemImage,
      category,
      price,
      sellerId,
      sellerName,
      sellerNumber,
      buyerId,
      buyerName,
      buyerNumber;

      bool completedStatus;

  Orders(
      this.orderId,
      this.itemName,
      this.itemDesc,
      this.itemImage,
      this.category,
      this.price,
      this.sellerId,
      this.sellerName,
      this.sellerNumber,
      this.buyerId,
      this.buyerName,
      this.buyerNumber, this.completedStatus);
}
