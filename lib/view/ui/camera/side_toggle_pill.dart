import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

enum DocumentSide { front, back }

class SideTogglePill extends StatelessWidget {
  final DocumentSide value;
  final ValueChanged<DocumentSide> onChanged;

  const SideTogglePill({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedStyle = const TextStyle(
      color: AppColors.black,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontFamily: 'Figtree',
      package: 'dataspikemobilesdk',
      decoration: TextDecoration.none,
    );
    final unselectedStyle = TextStyle(
      color: AppColors.blackTransparent,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontFamily: 'Figtree',
      package: 'dataspikemobilesdk',
      decoration: TextDecoration.none,
    );

    Widget segment(String text, bool selected, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Text(text, style: selected ? selectedStyle : unselectedStyle),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(
            'Front side',
            value == DocumentSide.front,
            () => onChanged(DocumentSide.front),
          ),
          SizedBox(width: 8.0),
          segment(
            'Reverse side',
            value == DocumentSide.back,
            () => onChanged(DocumentSide.back),
          ),
        ],
      ),
    );
  }
}