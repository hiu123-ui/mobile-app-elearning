import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'Làm sao để bắt đầu học lập trình?',
        'answer':
            'Chọn một ngôn ngữ (như JavaScript hoặc Python), học từ cơ bản và luyện tập mỗi ngày.',
      },
      {
        'question': 'Mỗi ngày nên học bao lâu là phù hợp?',
        'answer':
            'Khoảng 1–2 giờ tập trung, đều đặn mỗi ngày thường hiệu quả hơn học dồn.',
      },
      {
        'question': 'Có cần giỏi toán mới học được lập trình không?',
        'answer':
            'Không bắt buộc. Biết logic cơ bản là đủ cho hầu hết các mảng lập trình web.',
      },
      {
        'question': 'Làm thế nào để không nhanh chán khi tự học?',
        'answer':
            'Đặt mục tiêu nhỏ, làm project đơn giản và học cùng cộng đồng hoặc bạn bè.',
      },
      {
        'question': 'Khi nào nên bắt đầu làm dự án thực tế?',
        'answer':
            'Ngay khi nắm được kiến thức cơ bản, hãy bắt đầu với các project nhỏ để luyện tay.',
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(
              title: 'Bài Viết Hữu Ích',
              subtitle: 'Một số bài viết hữu ích khi học lập trình',
              showBackButton: true,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final item = faqs[index];
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: index < faqs.length - 1 ? 12 : 0,
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF)
                                        .withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.question_mark,
                                      size: 16,
                                      color: Color(0xFF6C63FF),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item['question'] as String,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 26),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item['answer'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/courses');
          } else if (index == 2) {
          } else if (index == 3) {
            Navigator.pushNamed(context, '/account');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Khóa học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed_outlined),
            activeIcon: Icon(Icons.rss_feed),
            label: 'Bài viết',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

