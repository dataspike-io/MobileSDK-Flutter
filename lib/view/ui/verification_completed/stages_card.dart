import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import '../onboarding/stage_row.dart';

class StagesCard extends StatefulWidget {
  final List<Stage> stages;

  const StagesCard({
    super.key,
    required this.stages,
  });

  @override
  State<StagesCard> createState() => _StagesCardState();
}

class _StagesCardState extends State<StagesCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.palePeriwinkle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.stages.map((s) => StageRow(stage: s)),
        ],
      ),
    );
  }
}
