import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import '../verification_completed/verification_stage_row.dart';

class VerificationStagesCard extends StatefulWidget {
  final List<VerificationStage> stages;

  const VerificationStagesCard({
    super.key,
    required this.stages,
  });

  @override
  State<VerificationStagesCard> createState() => _VerificationStagesCardState();
}

class _VerificationStagesCardState extends State<VerificationStagesCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.palePeriwinkle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.stages.map((s) => VerificationStageRow(stage: s)),
        ],
      ),
    );
  }
}
