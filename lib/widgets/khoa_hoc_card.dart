// [file name]: widgets/khoa_hoc_card.dart
import 'package:flutter/material.dart';
import '../models/khoa_hoc_model.dart';

class KhoaHocCard extends StatelessWidget {
  final KhoaHocModel khoaHoc;
  final VoidCallback onTap;
  final String? imageUrl;
  final bool registered;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? primaryLabel;
  final Color? primaryColor;

  const KhoaHocCard({
    super.key,
    required this.khoaHoc,
    required this.onTap,
    this.imageUrl,
    this.registered = false,
    this.secondaryLabel,
    this.onSecondary,
    this.primaryLabel,
    this.primaryColor,
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
      onTap: registered ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 3), // Giảm mạnh

                  Text(
                    khoaHoc.moTa,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6), // Giảm để sát rating hơn

                  _buildRatingAndStudents(),
                  const SizedBox(height: 10), // Khoảng cách vừa đủ trước button

                  _buildActionButtons(),
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
              child: Builder(
                builder: (context) {
                  final primaryUrl = _normalizeUrl(
                    (imageUrl != null && imageUrl!.trim().isNotEmpty)
                        ? imageUrl
                        : (khoaHoc.hinhAnh.isNotEmpty ? khoaHoc.hinhAnh : _fallbackImageUrl),
                  );
                  return Image.network(
                    primaryUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    headers: const {'User-Agent': 'Mozilla/5.0 (Flutter)'},
                    errorBuilder: (context, error, stackTrace) {
                      if (primaryUrl != _fallbackImageUrl) {
                        return Image.network(
                          _fallbackImageUrl,
                          fit: BoxFit.cover,
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
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.15)],
              ),
            ),
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Giảm padding để nhỏ gọn hơn
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber), // Giảm size icon nhẹ
              const SizedBox(width: 3),
              Text(
                khoaHoc.danhGia,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  '${khoaHoc.soLuongHocVien} học viên',
                  style: TextStyle(
                    fontSize: 12.5,
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

  Widget _buildActionButtons() {
    if (registered) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEEEEE),
                  foregroundColor: const Color(0xFF616161),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 1,
                ),
                child: Text(
                  primaryLabel ?? 'Đã đăng ký',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: onSecondary,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(secondaryLabel ?? 'Xóa'),
              ),
            ),
          ),
        ],
      );
    }
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor ?? const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 2,
          shadowColor: (primaryColor ?? const Color(0xFF6C63FF)).withOpacity(0.3),
        ),
        child: Text(
          primaryLabel ?? 'Xem Chi Tiết',
          style: const TextStyle(
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
        child: Center(
          child: Icon(registered ? Icons.verified : Icons.school, size: 18, color: Colors.white),
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
