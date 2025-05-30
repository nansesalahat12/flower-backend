class Rating {
  final String bouquetName;
  final int stars;
  final String comment;

  Rating({
    required this.bouquetName,
    required this.stars,
    required this.comment,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      bouquetName: json['bouquetName'] ?? '',
      stars: json['stars'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}
