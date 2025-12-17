// [file name]: widgets/khoa_hoc_card.dart
import 'package:flutter/material.dart';
import '../models/khoa_hoc_model.dart';

class KhoaHocCard extends StatelessWidget {
  final KhoaHocModel khoaHoc;
  final VoidCallback onTap;

  const KhoaHocCard({
    super.key,
    required this.khoaHoc,
    required this.onTap,
  });

  // URL ảnh cứng bạn muốn ghép vào mọi card
  static const String _hardcodedImageUrl =
      'https://ectimes.wordpress.com/wp-content/uploads/2019/03/cac-ngon-ngu-lap-trinh-pho-bien-2.jpg';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Phần ảnh cứng (luôn dùng URL cố định) ===
            _buildImageSection(),

            const SizedBox(height: 8), // Khoảng cách nhỏ giữa ảnh và nội dung

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề: chỉ 1 dòng, dài quá thì ...
                  Text(
                    khoaHoc.tenKhoaHoc,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Mô tả: tối đa 2 dòng, thừa thì ...
                  Text(
                    khoaHoc.moTa,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Rating + số học viên
                  _buildRatingAndStudents(),

                  const SizedBox(height: 16),

                  // Button luôn nằm cuối
                  _buildDetailButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Phần ảnh cứng ===
  Widget _buildImageSection() {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Image.network(
                _hardcodedImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          // Gradient overlay nhẹ (giữ nguyên như cũ)
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Rating & số học viên ===
  Widget _buildRatingAndStudents() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                khoaHoc.danhGia,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${khoaHoc.soLuongHocVien} học viên',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // === Button ===
  Widget _buildDetailButton() {
    return SizedBox(
      height: 38,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          shadowColor: const Color(0xFF6C63FF).withOpacity(0.3),
        ),
        child: const Text(
          'Xem Chi Tiết',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // === Placeholder nếu ảnh lỗi ===
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.school_rounded,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}