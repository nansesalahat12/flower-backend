class Order {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final List<Flower> flowers;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.flowers,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      customerName: json['customerName'],
      phone: json['phone'],
      address: json['address'],
      flowers: (json['flowers'] as List)
          .map((f) => Flower.fromJson(f))
          .toList(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'قيد التنفيذ',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Flower {
  final String flowerName;
  final int quantity;
  final double price;

  Flower({
    required this.flowerName,
    required this.quantity,
    required this.price,
  });

  factory Flower.fromJson(Map<String, dynamic> json) {
    return Flower(
      flowerName: json['flowerName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
