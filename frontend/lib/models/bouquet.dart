class Bouquet {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final bool isFavorite;
  final String userId;
  final String description;

  Bouquet({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.isFavorite,
    required this.userId,
    required this.description,
  });

  factory Bouquet.fromJson(Map<String, dynamic> json) {
    return Bouquet(
      id: json['_id'],
      name: json['name'],
      imageUrl: json['image'],
      price: (json['price'] as num).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      userId: json['userId'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': imageUrl,
      'price': price,
      'isFavorite': isFavorite,
      'userId': userId,
      'description': description,
    };
  }
}
