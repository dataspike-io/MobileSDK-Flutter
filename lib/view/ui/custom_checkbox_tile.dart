import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomCheckboxTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final InlineSpan text;

  const CustomCheckboxTile({
    required this.value,
    required this.onChanged,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(1),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 1),
                color: Colors.transparent,
              ),
              alignment: Alignment.center,
              child: value
                  ? SvgPicture.asset(
                      'packages/dataspikemobilesdk/assets/images/check_icon.svg',
                      height: 8.5,
                      width: 12,
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(text: text, textAlign: TextAlign.left),
          ),
        ],
      ),
    );
  }
}