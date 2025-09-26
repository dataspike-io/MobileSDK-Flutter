import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class RadioChoices extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  const RadioChoices({super.key, 
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            _RadioRow(
              text: options[i],
              selected: value == options[i],
              onTap: () => onChanged(options[i]),
            ),
            if (i < options.length - 1)
              Divider(height: 1, thickness: 1, color: AppColors.mistyLilac),
          ],
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            _CustomRadio(selected: selected),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Figtree',
                  package: 'dataspikemobilesdk',
                  fontWeight: FontWeight.w400,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomRadio extends StatelessWidget {
  final bool selected;
  const _CustomRadio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.royalPurple, width: 2),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.royalPurple : AppColors.clear,
        ),
      ),
    );
  }
}