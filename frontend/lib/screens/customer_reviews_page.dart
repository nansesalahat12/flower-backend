import 'package:flutter/material.dart';

class CustomerReviewsPage extends StatefulWidget {
  const CustomerReviewsPage({Key? key}) : super(key: key);

  @override
  State<CustomerReviewsPage> createState() => _CustomerReviewsPageState();
}

class _CustomerReviewsPageState extends State<CustomerReviewsPage> {
  final List<Map<String, dynamic>> reviews = [
    {
      'review': 'خدمة ممتازة والتوصيل كان سريع!',
      'author': 'عميل 1',
      'rating': 5,
      'avatarUrl': 'https://i.pravatar.cc/150?img=1',
      'reply': null,
      'showReplyField': false,
    },
    {
      'review': 'باقة الورد كانت أجمل مما توقعت!',
      'author': 'عميلة 2',
      'rating': 4,
      'avatarUrl': 'https://i.pravatar.cc/150?img=2',
      'reply': null,
      'showReplyField': false,
    },
    {
      'review': 'سهل الطلب والتواصل مع فريق الدعم رائع.',
      'author': 'عميل 3',
      'rating': 5,
      'avatarUrl': 'https://i.pravatar.cc/150?img=3',
      'reply': null,
      'showReplyField': false,
    },
  ];

  final Map<int, TextEditingController> _replyControllers = {};

  Widget buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else {
          return const Icon(Icons.star_border, color: Colors.grey, size: 18);
        }
      }),
    );
  }

  @override
  void dispose() {
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('آراء العملاء')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            _replyControllers.putIfAbsent(index, () => TextEditingController());

            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: Colors.pink.shade100,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(review['avatarUrl']),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['author'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            buildStarRating(review['rating']),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '\"${review['review']}\"',
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (review['reply'] != null)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.reply, color: Colors.pink, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                review['reply'],
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          review['showReplyField'] = !review['showReplyField'];
                        });
                      },
                      child: Text(
                        review['showReplyField'] ? 'إلغاء' : 'رد',
                        style: const TextStyle(color: Colors.pink),
                      ),
                    ),
                    if (review['showReplyField'])
                      Column(
                        children: [
                          TextField(
                            controller: _replyControllers[index],
                            decoration: const InputDecoration(
                              hintText: 'اكتب ردك هنا...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                review['reply'] = _replyControllers[index]!.text.trim();
                                review['showReplyField'] = false;
                                _replyControllers[index]!.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                            child: const Text('إرسال الرد'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
