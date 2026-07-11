import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationContentCard extends StatelessWidget {
  const EducationContentCard({super.key});

  static final Uri _videoUri = Uri.parse(
    'https://www.youtube.com/watch?v=7S-DGTBZU14',
  );

  Future<void> _openVideo(BuildContext context) async {
    final launched = await launchUrl(
      _videoUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở video giáo dục.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0F3460),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.school_outlined,
                color: Color(0xFFFFB347),
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kiến thức cần nhớ',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF5F5F5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _EducationItem(
            icon: Icons.trending_down,
            title: 'Càng gỡ càng dễ thua',
            description:
            'Khi đang thua, người chơi thường tăng tiền cược để mong lấy lại khoản đã mất. Điều này chỉ làm mức độ rủi ro tăng nhanh hơn.',
          ),
          const SizedBox(height: 14),
          const _EducationItem(
            icon: Icons.percent,
            title: 'Xác suất không nhớ ván trước',
            description:
            'Một chuỗi thua không làm cho lần cược tiếp theo có khả năng thắng cao hơn. Mỗi kết quả vẫn phụ thuộc vào xác suất riêng của nó.',
          ),
          const SizedBox(height: 14),
          const _EducationItem(
            icon: Icons.account_balance,
            title: 'Không vay tiền để cá cược',
            description:
            'Tiền vay tạo thêm áp lực trả nợ, lãi suất và dễ khiến người chơi tiếp tục cược trong trạng thái mất kiểm soát.',
          ),
          const SizedBox(height: 14),
          const _EducationItem(
            icon: Icons.pause_circle_outline,
            title: 'Dừng lại là một quyết định đúng',
            description:
            'Khi số dư xuống thấp, hãy rời ứng dụng, nghỉ ngơi và xem lại lịch sử giao dịch thay vì tiếp tục đặt cược.',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openVideo(context),
              icon: const Icon(
                Icons.play_circle_fill,
              ),
              label: const Text(
                'XEM VIDEO GIÁO DỤC',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFB347),
                side: const BorderSide(
                  color: Color(0xFFFFB347),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EducationItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF0F3460),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00D4AA),
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 13,
                  color: Color(0xFFA0A0B0),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}