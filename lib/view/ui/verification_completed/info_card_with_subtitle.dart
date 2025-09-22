import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class InfoCardWithSubtitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String copyValue;
  final String linkText;

  const InfoCardWithSubtitle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.copyValue,
    required this.linkText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mistyLilac,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'packages/dataspikemobilesdk/assets/images/jp_logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black,
                    fontFamily: 'Figtree',
                    package: 'dataspikemobilesdk',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.cadetBlue,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkIndigo,
                    fontFamily: 'Figtree',
                    package: 'dataspikemobilesdk',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: copyValue));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.content_copy_outlined,
                        size: 16,
                        color: AppColors.black,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        linkText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.royalPurple,
                          fontFamily: 'Figtree',
                          package: 'dataspikemobilesdk',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}