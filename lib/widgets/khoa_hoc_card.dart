// [file name]: widgets/khoa_hoc_card.dart
import 'package:flutter/material.dart';
import '../models/khoa_hoc_model.dart';

class KhoaHocCard extends StatelessWidget {
  final KhoaHocModel khoaHoc;
  final VoidCallback onTap;
  final String? imageUrl;

  const KhoaHocCard({
    super.key,
    required this.khoaHoc,
    required this.onTap,
    this.imageUrl,
  });

  static const String _fallbackImageUrl =
      'https://ectimes.wordpress.com/wp-content/uploads/2019/03/cac-ngon-ngu-lap-trinh-pho-bien-2.jpg';

  String _normalizeUrl(String? url) {
    final s = (url ?? '').trim().replaceAll('`', '').replaceAll('"', '').replaceAll("'", '');
    if (s.isEmpty) return _fallbackImageUrl;
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    return 'https://$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),

            // === BỎ Expanded + Spacer + SizedBox thừa → loại bỏ khoảng trắng và overflow ===
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    khoaHoc.tenKhoaHoc,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Mô tả
                  Text(
                    khoaHoc.moTa,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[700],
                      height: 1.35,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Rating + số học viên
                  _buildRatingAndStudents(),
                  const SizedBox(height: 6),

                  // Nút Xem Chi Tiết - full width, sát đáy
                  _buildDetailButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Builder(
                builder: (context) {
                  final primaryUrl = _normalizeUrl(
                    (imageUrl != null && imageUrl!.trim().isNotEmpty)
                        ? imageUrl
                        : (khoaHoc.hinhAnh.isNotEmpty ? khoaHoc.hinhAnh : _fallbackImageUrl),
                  );
                  return Image.network(
                    primaryUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    headers: const {'User-Agent': 'Mozilla/5.0 (Flutter)'},
                    errorBuilder: (context, error, stackTrace) {
                      if (primaryUrl != _fallbackImageUrl) {
                        return Image.network(
                          _fallbackImageUrl,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                          headers: const {'User-Agent': 'Mozilla/5.0 (Flutter)'},
                          errorBuilder: (c, e, s) => _buildImagePlaceholder(),
                        );
                      }
                      return _buildImagePlaceholder();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF6C63FF),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
              ),
            ),
          ),
          // Badge
          Positioned(
            top: 10,
            left: 10,
            child: _buildTopBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingAndStudents() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 15, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                khoaHoc.danhGia,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Icon(Icons.people_outline, size: 15, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${khoaHoc.soLuongHocVien} học viên',
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildDetailButton() {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF6C63FF).withOpacity(0.3),
        ),
        child: const Text(
          'Xem Chi Tiết',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBadge() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF7A73FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.school, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.school_rounded,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}
