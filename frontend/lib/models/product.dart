class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  final String color;
  final bool exclusive;
  final bool bestSeller;
  final bool topPick;
  final int stock;
  final DateTime? createdAt;

  Product({
    this.id = '',
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.color,
    this.exclusive = false,
    this.bestSeller = false,
    this.topPick = false,
    this.stock = 0,
    this.createdAt,
  });

  String get fullImageUrl {
    return imageUrl.startsWith('http')
        ? imageUrl
        : 'http://192.168.1.15:3000/uploads/$imageUrl';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'color': color,
      'exclusive': exclusive,
      'best_seller': bestSeller,
      'top_pick': topPick,
      'stock': stock,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      color: json['color'] ?? '',
      exclusive: json['exclusive'] ?? false,
      bestSeller: json['best_seller'] ?? false,
      topPick: json['top_pick'] ?? false,
      stock: json['stock'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
