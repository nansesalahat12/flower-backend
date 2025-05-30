import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/rating.dart';

class MyRatingsPage extends StatefulWidget {
  final String userId;

  const MyRatingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyRatingsPage> createState() => _MyRatingsPageState();
}

class _MyRatingsPageState extends State<MyRatingsPage> {
  List<Rating> ratings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRatings();
  }

  Future<void> fetchRatings() async {
    try {
      final url = Uri.parse('http://192.168.1.15:3000/api/ratings/user/${widget.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          ratings = data.map((e) => Rating.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('فشل في تحميل التقييمات');
      }
    } catch (e) {
      print('Error fetching ratings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييماتي'),
        backgroundColor: Colors.pink,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ratings.isEmpty
              ? const Center(child: Text('لا يوجد تقييمات بعد.'))
              : ListView.builder(
                  itemCount: ratings.length,
                  itemBuilder: (context, index) {
                    final rating = ratings[index];
                    return ListTile(
                      title: Text(rating.bouquetName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('التقييم: ${'⭐' * rating.stars.clamp(1, 5)}'),
                          Text('تعليق: ${rating.comment}'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
