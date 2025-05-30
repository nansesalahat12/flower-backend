import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['productId'];

    return CartItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(), // 🔒 حماية ضد null
      quantity: json['quantity'] ?? 1,
      product: productData is Map<String, dynamic>
          ? Product.fromJson(productData)
          : Product(
              id: productData.toString(),
              name: json['name'] ?? '',
              price: (json['price'] ?? 0).toDouble(),
              description: json['description'] ?? '',
              imageUrl: json['imageUrl'] ?? '',
              category: json['category'] ?? '',
              color: json['color'] ?? '',
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'quantity': quantity,
      'productId': {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'color': product.color,
        'exclusive': product.exclusive,
        'best_seller': product.bestSeller,
        'top_pick': product.topPick,
        'stock': product.stock,
        'createdAt': product.createdAt?.toIso8601String(),
      },
    };
  }
}
