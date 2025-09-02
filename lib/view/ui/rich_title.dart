
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class RichTitle extends StatelessWidget {
  final String full;
  final String linkWord;
  const RichTitle({super.key, required this.full, required this.linkWord});

  @override
  Widget build(BuildContext context) {
    final idx = full.toLowerCase().indexOf(linkWord.toLowerCase());
    if (idx < 0) {
      return Text(
        full,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 20,
          fontFamily: 'Mont',
          package: 'dataspikemobilesdk',
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      );
    }

    final before = full.substring(0, idx);
    final link = full.substring(idx, idx + linkWord.length);
    final after = full.substring(idx + linkWord.length);

    return RichText(
      textAlign: TextAlign.start,
      maxLines: 2,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 20,
          fontFamily: 'Mont',
          package: 'dataspikemobilesdk',
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        children: [
          TextSpan(text: before),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.accent, width: 2),
                  ),
                ),
                child: Text(
                  link,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Mont',
                    package: 'dataspikemobilesdk',
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
